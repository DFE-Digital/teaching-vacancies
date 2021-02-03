require "rails_helper"

RSpec.describe Jobseekers::NqtJobAlertsForm, type: :model do
  subject { described_class.new(params) }

  let(:keywords) { "some keywords" }
  let(:location) { "some place" }
  let(:email) { "test@email.com" }
  let(:params) { { keywords: keywords, location: location, email: email } }

  it { is_expected.to validate_presence_of(:keywords) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to allow_value("thestrokes@example.com").for(:email) }
  it { is_expected.not_to allow_value("invalid-email").for(:email) }

  context "when location is blank" do
    let(:location) { "" }

    it "validates presence of location" do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:location]).to include(I18n.t("nqt_job_alert_errors.location.blank"))
    end
  end

  context "when job alert already exists" do
    before { allow(SubscriptionFinder).to receive_message_chain(:new, :exists?).and_return(true) }

    it "validates uniqueness of job alert" do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.duplicate_alert"))
    end
  end

  describe "#job_alert_params" do
    let(:expected_hash) { { keyword: "nqt #{keywords}", location: location, radius: 10 } }

    context "when location is not a LocationPolygon" do
      before { allow(LocationPolygon).to receive(:include?).with(location).and_return(false) }

      it "adds location to the search criteria" do
        expect(subject.job_alert_params[:search_criteria]).to eq(expected_hash)
      end
    end

    context "when location is a LocationPolygon" do
      before { allow(LocationPolygon).to receive(:include?).with(location).and_return(true) }

      it "sets the location paramter in the search criteria to the polygon's name" do
        expect(subject.job_alert_params[:search_criteria]).to eq(expected_hash)
      end
    end
  end
end
