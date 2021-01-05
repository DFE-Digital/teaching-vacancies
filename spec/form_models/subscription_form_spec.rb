require "rails_helper"

RSpec.describe SubscriptionForm, type: :model do
  let(:subject) { described_class.new(params) }

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
    let(:params) { { email: email, frequency: frequency, keyword: keyword } }
    let(:email) { "test@email.com" }
    let(:frequency) { "daily" }
    let(:keyword) { "maths" }

    describe "#email" do
      context "when email is blank" do
        let(:email) { nil }

        it "validates email presence" do
          expect(subject.valid?).to be(false)
          expect(subject.errors.messages[:email]).to include(
            I18n.t("activemodel.errors.models.subscription_form.attributes.email.blank"),
          )
        end
      end

      context "when email is invalid" do
        let(:email) { "invalid_email" }

        it "validates email validity" do
          expect(subject.valid?).to be(false)
          expect(subject.errors.messages[:email]).to include(
            I18n.t("activemodel.errors.models.subscription_form.attributes.email.invalid"),
          )
        end
      end
    end

    context "when frequency is blank" do
      let(:frequency) { nil }

      it "validates email presence" do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:frequency]).to include(
          I18n.t("activemodel.errors.models.subscription_form.attributes.frequency.blank"),
        )
      end
    end

    context "when job alert already exists" do
      before do
        allow(SubscriptionFinder).to receive_message_chain(:new, :exists?).and_return(true)
      end

      it "validates uniqueness of job alert" do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:base]).to include(
          I18n.t("subscriptions.errors.duplicate_alert"),
        )
      end
    end

    context "when no criteria are selected" do
      let(:keyword) { nil }

      it "validates job alert criteria selected" do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:base]).to include(
          I18n.t("subscriptions.errors.no_criteria_selected"),
        )
      end
    end
  end
end
