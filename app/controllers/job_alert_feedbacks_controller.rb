class JobAlertFeedbacksController < ApplicationController
  def new
    # This action creates the JobAlertFeedback record.
    # This is because it is called from a link in the alert email. Such links can only perform
    # GET requests. HTTP forbids redirecting from GET to POST.
    subscription = Subscription.find_and_verify_by_token(token)

    @feedback = subscription.job_alert_feedbacks.create(job_alert_feedback_params)

    Auditor::Audit.new(@feedback, "job_alert_feedback.create", current_publisher_oid).log
    redirect_to edit_subscription_job_alert_feedback_path(id: @feedback.id), success: t(".success")
  end

  def edit
    @feedback = JobAlertFeedback.find(feedback_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback_form = Jobseekers::JobAlertFeedbackForm.new
  end

  def update
    @feedback = JobAlertFeedback.find(feedback_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback_form = Jobseekers::JobAlertFeedbackForm.new(form_params)

    recaptcha_is_valid = verify_recaptcha(model: @feedback, action: "job_alert_feedback")
    @feedback.recaptcha_score = recaptcha_reply["score"] if recaptcha_is_valid && recaptcha_reply
    @feedback.save

    if recaptcha_is_valid && recaptcha_reply && invalid_recaptcha_score?
      redirect_to invalid_recaptcha_path(form_name: @feedback.class.name.underscore.humanize)
    elsif @feedback_form.valid?
      @feedback.update(form_params)
      Auditor::Audit.new(@feedback, "job_alert_feedback.update", current_publisher_oid).log
      redirect_to root_path, success: t(".success")
    else
      render :edit
    end
  end

  private

  def job_alert_feedback_params
    params.require(:job_alert_feedback).permit(:comment, :relevant_to_user, :search_criteria, search_criteria: {}, vacancy_ids: [])
  end

  def form_params
    params.require(:jobseekers_job_alert_feedback_form).permit(:comment)
  end

  def token
    params.require(:subscription_id)
  end

  def feedback_id
    params.require(:id)
  end
end
