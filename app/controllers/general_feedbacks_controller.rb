class GeneralFeedbacksController < ApplicationController
  def new
    @general_feedback_form = GeneralFeedbackForm.new
  end

  def create
    @general_feedback_form = GeneralFeedbackForm.new(feedback_params)
    @feedback = Feedback.new(feedback_params)

    if @general_feedback_form.invalid?
      render :new
    elsif recaptcha_is_invalid?(@feedback)
      redirect_to invalid_recaptcha_path(form_name: @general_feedback_form.class.name.underscore.humanize)
    else
      @feedback.recaptcha_score = recaptcha_reply["score"]
      @feedback.save
      trigger_feedback_provided_event
      redirect_to root_path, success: t(".success")
    end
  end

  private

  def feedback_params
    params.require(:general_feedback_form)
          .permit(:comment, :email, :user_participation_response, :visit_purpose, :visit_purpose_comment)
          .merge(feedback_type: "general")
  end
end
