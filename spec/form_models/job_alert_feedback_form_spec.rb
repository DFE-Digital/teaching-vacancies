require "rails_helper"

RSpec.describe JobAlertFeedbackForm, type: :model do
  let(:subject) { described_class.new(params) }
  let(:params) { { comment: comment } }

  describe "validations" do
    describe "#comment" do
      context "when comment is blank" do
        let(:comment) { nil }

        it "requests an entry in the field" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:comment]).to include(
            I18n.t("activemodel.errors.models.job_alert_feedback_form.attributes.comment.blank"),
          )
        end
      end

      context "when comment is too long" do
        let(:comment) { (1..1000).to_a.join("") }

        it "returns the correct error" do
          expect(subject).not_to be_valid
          expect(subject.errors.messages[:comment]).to include(
            I18n.t("activemodel.errors.models.job_alert_feedback_form.attributes.comment.too_long"),
          )
        end
      end
    end
  end

  context "when all attributes are valid" do
    let(:comment) { "Decent alert" }

    it "is valid" do
      expect(subject).to be_valid
    end
  end
end
