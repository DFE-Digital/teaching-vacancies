class GeneralFeedbacksController < ApplicationController
  def new
    @general_feedback_form = GeneralFeedbackForm.new
  end

  def create
    @general_feedback_form = GeneralFeedbackForm.new(feedback_params)
    @feedback = Feedback.new(feedback_params)

    recaptcha_is_valid = verify_recaptcha(model: @feedback, action: "feedback")
    @feedback.recaptcha_score = recaptcha_reply["score"] if recaptcha_is_valid && recaptcha_reply

    if recaptcha_is_valid && recaptcha_reply && invalid_recaptcha_score?
      redirect_to invalid_recaptcha_path(form_name: @general_feedback_form.class.name.underscore.humanize)
    elsif @general_feedback_form.valid?
      @feedback.save
      trigger_feedback_provided_event
      redirect_to root_path, success: t(".success")
    else
      render :new
    end
  end

  private

  def feedback_params
    params.require(:general_feedback_form)
          .permit(:comment, :email, :user_participation_response, :visit_purpose, :visit_purpose_comment)
          .merge(feedback_type: "general")
  end
end
