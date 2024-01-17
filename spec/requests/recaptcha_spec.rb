require "rails_helper"

RSpec.describe "General feedback can interface with recaptcha", recaptcha: true do
  let(:feedback) { instance_double(Feedback).as_null_object }
  let(:feedback_form) { instance_double(GeneralFeedbackForm) }

  before do
    allow(Feedback).to receive(:new).and_return(feedback)
    allow(GeneralFeedbackForm).to receive(:new).and_return(feedback_form)
    allow(feedback_form).to receive(:invalid?).and_return(false)
    allow(feedback_form).to receive(:class).and_return(GeneralFeedbackForm)
  end

  it "sends the action, and minimum score (all required) when it verifies the recaptcha" do
    expect_any_instance_of(ApplicationController).to receive(:verify_recaptcha)
                      .with(model: nil,
                            action: "general_feedbacks",
                            minimum_score: ApplicationController::SUSPICIOUS_RECAPTCHA_THRESHOLD)
    post feedback_path, params: { general_feedback_form: attributes_for(:feedback) }
  end

  it "sets the recaptcha score on the Feedback record" do
    expect(feedback).to receive(:recaptcha_score=).with(0.9)
    post feedback_path, params: { general_feedback_form: attributes_for(:feedback) }
  end
end
