class Jobseekers::JobAlertFeedbacksController < ApplicationController
  def new
    # The `new` action creates the Feedback record because it is called from a link in the alert email.
    # Such links can only perform GET requests. HTTP forbids redirecting from GET to POST.
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback = Feedback.create(new_feedback_attributes)
    redirect_to edit_subscription_job_alert_feedback_path(id: @feedback.id), success: t(".success")
  end

  def edit
    @feedback = Feedback.find(feedback_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback_form = Jobseekers::JobAlertFurtherFeedbackForm.new
  end

  def update
    @feedback = Feedback.find(feedback_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback_form = Jobseekers::JobAlertFurtherFeedbackForm.new(further_feedback_form_params)

    if @feedback_form.invalid?
      render :edit
    elsif recaptcha_is_invalid?
      redirect_to invalid_recaptcha_path(form_name: @feedback_form.class.name.gsub("::", "").underscore.humanize)
    else
      @feedback.update(further_feedback_form_params)
      @feedback.recaptcha_score = recaptcha_reply["score"]
      @feedback.save
      redirect_to root_path, success: t(".success")
    end
  end

  private

  def new_feedback_attributes
    job_alert_email_link_params.merge(
      { feedback_type: "job_alert", search_criteria: @subscription.search_criteria, subscription_id: @subscription.id },
    )
  end

  def job_alert_email_link_params
    params.require(:job_alert_feedback)
          .permit(:relevant_to_user, search_criteria: {}, job_alert_vacancy_ids: [])
  end

  def further_feedback_form_params
    params.require(:jobseekers_job_alert_further_feedback_form).permit(:comment, :email, :user_participation_response)
  end

  def token
    params.require(:subscription_id)
  end

  def feedback_id
    params.require(:id)
  end
end
