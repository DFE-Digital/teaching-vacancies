class GeneralFeedbackController < ApplicationController
  def new
    @feedback = GeneralFeedback.new
  end

  def create
    @feedback = GeneralFeedback.new(general_feedback_params)

    recaptcha_is_valid = verify_recaptcha(model: @feedback, action: "feedback")
    @feedback.recaptcha_score = recaptcha_reply["score"] if recaptcha_is_valid && recaptcha_reply

    if recaptcha_is_valid && recaptcha_reply && invalid_recaptcha_score?
      redirect_to invalid_recaptcha_path(form_name: @feedback.class.name.underscore.humanize)
    elsif @feedback.valid?
      @feedback.save
      redirect_to root_path, success: t(".success")
    else
      render :new
    end
  end

  private

  def general_feedback_params
    params.require(:general_feedback)
          .permit(:visit_purpose, :visit_purpose_comment, :comment, :user_participation_response, :email)
  end
end
