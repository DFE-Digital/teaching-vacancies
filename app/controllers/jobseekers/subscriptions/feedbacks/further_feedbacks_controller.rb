class Jobseekers::Subscriptions::Feedbacks::FurtherFeedbacksController < ApplicationController
  include RecaptchaChecking

  def new
    @feedback_form = Jobseekers::JobAlertFurtherFeedbackForm.new
  end

  def create
    @feedback_form = Jobseekers::JobAlertFurtherFeedbackForm.new(further_feedback_form_params)

    if @feedback_form.invalid?
      render :new
    else
      log_invalid_recaptcha(form: @feedback_form, score: recaptcha_reply["score"]) if recaptcha_is_invalid?
      update_feedback
      redirect_to root_path, success: t(".success")
    end
  end

  private

  def further_feedback_form_params
    params.require(:jobseekers_job_alert_further_feedback_form).permit(:comment, :email, :user_participation_response, :occupation)
  end

  def update_feedback
    feedback.update(further_feedback_form_params)
    feedback.recaptcha_score = recaptcha_reply&.dig("score")
    feedback.save
  end

  def feedback
    @feedback ||= Feedback.find(params.require(:feedback_id))
  end
  helper_method :feedback

  def subscription
    @subscription ||= Subscription.find(params.require(:subscription_id))
  end
  helper_method :subscription
end
