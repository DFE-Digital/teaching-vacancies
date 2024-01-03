class Jobseekers::Subscriptions::Feedbacks::FurtherFeedbacksController < ApplicationController
  def new
    @feedback_form = Jobseekers::JobAlertFurtherFeedbackForm.new
  end

  def create
    @feedback_form = Jobseekers::JobAlertFurtherFeedbackForm.new(further_feedback_form_params)

    if @feedback_form.invalid?
      render :new
    elsif recaptcha_is_invalid?
      redirect_to invalid_recaptcha_path(form_name: @feedback_form.class.name.gsub("::", "").underscore.humanize,
                                         recaptcha_score: recaptcha_reply["score"])
    else
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
    feedback.recaptcha_score = recaptcha_reply["score"]
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
