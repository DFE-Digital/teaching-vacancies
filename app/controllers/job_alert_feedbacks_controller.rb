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

    if @feedback_form.invalid?
      render :edit
    elsif recaptcha_is_invalid?(@feedback)
      redirect_to invalid_recaptcha_path(form_name: @feedback.class.name.underscore.humanize)
    else
      @feedback.update(form_params)
      @feedback.recaptcha_score = recaptcha_reply["score"]
      @feedback.save
      Auditor::Audit.new(@feedback, "job_alert_feedback.update", current_publisher_oid).log
      redirect_to root_path, success: t(".success")
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
