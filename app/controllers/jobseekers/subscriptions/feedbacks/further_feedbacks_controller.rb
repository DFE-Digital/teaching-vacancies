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
      recaptcha_protected(form: @feedback_form) do
        update_feedback
        redirect_to root_path, success: t(".success")
      end
    end
  end

  private

  def further_feedback_form_params
    params.expect(jobseekers_job_alert_further_feedback_form: %i[comment email user_participation_response occupation])
  end

  def update_feedback
    feedback.update(further_feedback_form_params)
    # tricky to auto-test where recaptcha-reply is nil
    # :nocov:
    feedback.recaptcha_score = recaptcha_reply&.score
    # :nocov:
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
