require "rails_helper"

RSpec.describe NqtJobAlertsForm, type: :model do
  let(:keywords) { "some keywords" }
  let(:location) { "some place" }
  let(:email) { "test@email.com" }
  let(:params) { { keywords: keywords, location: location, email: email } }
  let(:subject) { described_class.new(params) }

  describe "#job_alert_params" do
    context "when location is a LocationCategory" do
      let(:expected_hash) do
        { keyword: "nqt #{keywords}", location: location, radius: 10, location_category: location }
      end

      before do
        allow(LocationCategory).to receive(:include?).with(location).and_return(true)
      end

      it "adds location_category to the search criteria" do
        expect(subject.job_alert_params[:search_criteria]).to eql(expected_hash.to_json)
      end
    end

    context "when location is not a LocationCategory" do
      let(:expected_hash) do
        { keyword: "nqt #{keywords}", location: location, radius: 10 }
      end

      before do
        allow(LocationCategory).to receive(:include?).with(location).and_return(false)
      end

      it "does not add location_category to the search criteria" do
        expect(subject.job_alert_params[:search_criteria]).to eql(expected_hash.to_json)
      end
    end
  end

  describe "#validations" do
    context "when keywords is blank" do
      let(:keywords) { "" }

      it "validates presence of keywords" do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:keywords]).to include(
          I18n.t("activemodel.errors.models.nqt_job_alerts_form.attributes.keywords.blank"),
        )
      end
    end

    context "when location is blank" do
      let(:location) { "" }

      it "validates presence of location" do
        expect(subject.valid?).to be(false)
        expect(subject.errors.messages[:location]).to include(
          I18n.t("activemodel.errors.models.nqt_job_alerts_form.attributes.location.blank"),
        )
      end
    end

    describe "#email" do
      context "when email is blank" do
        let(:email) { "" }

        it "validates presence of email" do
          expect(subject.valid?).to be(false)
          expect(subject.errors.messages[:email]).to include(
            I18n.t("activemodel.errors.models.nqt_job_alerts_form.attributes.email.blank"),
          )
        end
      end

      context "when email is invalid" do
        let(:email) { "invalid" }

        it "validates validity of email" do
          expect(subject.valid?).to be(false)
          expect(subject.errors.messages[:email]).to include(
            I18n.t("activemodel.errors.models.nqt_job_alerts_form.attributes.email.invalid"),
          )
        end
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
  end
end
