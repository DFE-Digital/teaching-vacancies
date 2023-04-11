class Jobseekers::Subscriptions::Feedbacks::RelevanceFeedbacksController < ApplicationController
  def submit_feedback
    partially_completed_feedback = Feedback.create(relevance_feedback_params)

    redirect_to new_subscription_feedback_further_feedback_path(subscription, partially_completed_feedback), success: t(".success")
  end

  private

  def relevance_feedback_params
    params.require(:job_alert_relevance_feedback)
          .permit(:relevant_to_user, search_criteria: {}, job_alert_vacancy_ids: [])
          .merge(feedback_type: "job_alert", subscription_id: subscription.id, jobseeker_id: current_jobseeker&.id || jobseeker_from_subscription_email&.id)
  end

  def subscription
    @subscription ||= Subscription.find_and_verify_by_token(params.require(:subscription_id))
  end

  def jobseeker_from_subscription_email
    Jobseeker.find_by_email(subscription.email)
  end
end
