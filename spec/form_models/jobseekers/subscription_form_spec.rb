require "rails_helper"

RSpec.describe Jobseekers::SubscriptionForm, type: :model do
  subject { described_class.new(params) }

  describe "#search_criteria_hash" do
    let(:params) { { keyword: keyword, job_roles: job_roles } }
    let(:keyword) { "physics" }
    let(:job_roles) { %w[teacher] }

    context "when a value is blank" do
      let(:keyword) { nil }

      it "is deleted from the hash" do
        expect(subject.search_criteria_hash).to eq({ job_roles: job_roles })
      end
    end

    context "when a value is empty" do
      let(:job_roles) { [] }

      it "is deleted from the hash" do
        expect(subject.search_criteria_hash).to eq({ keyword: keyword })
      end
    end
  end

  describe "#validations" do
    let(:params) { {} }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:frequency) }
    it { is_expected.to allow_value("valid@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }

    context "when job alert already exists" do
      let(:params) { { email: "test@email.com", frequency: "daily", keyword: "maths" } }

      before { allow(Subscription).to receive_message_chain(:where, :exists?).and_return(true) }

      it "validates uniqueness of job alert" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.duplicate_alert"))
      end
    end

    context "when default variant has been applied" do
      let(:params) { { variant: :default } }

      context "when no criteria are selected" do
        it "validates job alert criteria selected" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_criteria_selected"))
        end
      end

      context "when location and no other field are selected" do
        let(:params) { { variant: :default, location: "London" } }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end

    context "when mandatory_location_and_one_other_field variant has been applied" do
      context "when location and no other field are selected" do
        let(:params) { { variant: :mandatory_location_and_one_other_field, location: "London" } }

        it "validates location_and_one_other_criterion_selected" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_location_or_other_criterion_selected"))
        end
      end

      context "when one other field selected but no location" do
        let(:params) { { variant: :mandatory_location_and_one_other_field, keyword: "Maths" } }

        it "validates location_and_one_other_criterion_selected" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_location_or_other_criterion_selected"))
        end
      end
    end
  end
end
