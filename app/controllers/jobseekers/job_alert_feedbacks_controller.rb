class Jobseekers::JobAlertFeedbacksController < ApplicationController
  def new
    # This action creates the JobAlertFeedback record.
    # This is because it is called from a link in the alert email. Such links can only perform
    # GET requests. HTTP forbids redirecting from GET to POST.

    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback = Feedback.create(feedback_params)

    trigger_feedback_provided_event
    redirect_to edit_subscription_job_alert_feedback_path(id: @feedback.id), success: t(".success")
  end

  def edit
    @feedback = Feedback.find(feedback_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback_form = Jobseekers::JobAlertFeedbackForm.new
  end

  def update
    @feedback = Feedback.find(feedback_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @feedback_form = Jobseekers::JobAlertFeedbackForm.new(form_params)

    if @feedback_form.invalid?
      render :edit
    elsif recaptcha_is_invalid?(@feedback)
      redirect_to invalid_recaptcha_path(form_name: @feedback_form.class.name.gsub("::", "").underscore.humanize)
    else
      @feedback.update(form_params)
      @feedback.recaptcha_score = recaptcha_reply["score"]
      @feedback.save
      trigger_feedback_provided_event
      redirect_to root_path, success: t(".success")
    end
  end

  private

  def feedback_params
    # `trigger_feedback_provided_event`, which we use to create Events, relies on feedback_params. Hence this slightly
    # unconventional, abstracted feedback_params method, which allows events to be created for either type of action.
    # Here felt like the best place for this logic, since job alert feedback is the only feedback type that has >1 action.
    case action_name
    when "new"
      # The duplication here is because of the old-style params provided in links in emails that have already been sent.
      # TODO: drop the left-most version of each duplication after e.g. 30 days, and the transformation.
      params.require(:job_alert_feedback)
            .permit(:relevant_to_user, :search_criteria, search_criteria: {}, vacancy_ids: [], job_alert_vacancy_ids: [])
            .merge(feedback_type: "job_alert", subscription_id: @subscription.id)
            .transform_keys { |key| key == "vacancy_ids" ? "job_alert_vacancy_ids" : key }
    when "update"
      form_params.merge(feedback_type: "job_alert", subscription_id: @subscription.id)
    end
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
