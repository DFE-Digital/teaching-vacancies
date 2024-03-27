require "rails_helper"

RSpec.describe "General feedback can interface with recaptcha", recaptcha: true do
  let(:feedback_params) { { general_feedback_form: attributes_for(:feedback).merge(report_a_problem: "no") } }

  before do
    expect_any_instance_of(ApplicationController)
      .to receive(:verify_recaptcha)
      .with(action: "general_feedbacks",
            minimum_score: GeneralFeedbacksController::SUSPICIOUS_RECAPTCHA_V3_THRESHOLD,
            secret_key: ENV.fetch("RECAPTCHA_V3_SECRET_KEY", ""))
      .once.and_return(recaptcha_v3_success)
  end

  context "when recaptcha v3 verification passes" do
    let(:recaptcha_v3_success) { true }

    it "does not attempt recaptcha v2 check" do
      expect_any_instance_of(ApplicationController).not_to receive(:verify_recaptcha).with(no_args)
      post feedback_path, params: feedback_params
    end

    it "registers the feedback" do
      expect { post feedback_path, params: feedback_params }.to change(Feedback, :count).by(1)

      expect(response.body).not_to include(I18n.t("recaptcha.error"))
      expect(response.body).not_to include(I18n.t("recaptcha.label"))
    end
  end

  context "when recaptcha v3 verification fails" do
    let(:recaptcha_v3_success) { false }

    before do
      expect_any_instance_of(ApplicationController)
        .to receive(:verify_recaptcha).with(no_args).once.and_return(recaptcha_v2_success)
    end

    context "when user has verified recaptcha v2" do
      let(:recaptcha_v2_success) { true }

      it "registers the feedback" do
        expect { post feedback_path, params: feedback_params }.to change(Feedback, :count).by(1)

        expect(response.body).not_to include(I18n.t("recaptcha.error"))
        expect(response.body).not_to include(I18n.t("recaptcha.label"))
      end
    end

    context "when recaptcha v2 is not satisfied" do
      let(:recaptcha_v2_success) { false }

      it "shows recaptcha v2 check in the form" do
        expect { post feedback_path, params: feedback_params }.not_to change(Feedback, :count)

        expect(response.body).to include(I18n.t("recaptcha.error"))
        expect(response.body).to include(I18n.t("recaptcha.label"))
      end
    end
  end
end
