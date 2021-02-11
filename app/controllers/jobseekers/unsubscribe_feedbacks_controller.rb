class Jobseekers::UnsubscribeFeedbacksController < ApplicationController
  include FeedbackEventConcerns

  def new
    @subscription = Subscription.find(subscription_id)
    @unsubscribe_feedback_form = Jobseekers::UnsubscribeFeedbackForm.new
  end

  def create
    @subscription = Subscription.find(subscription_id)
    @unsubscribe_feedback_form = Jobseekers::UnsubscribeFeedbackForm.new(unsubscribe_feedback_form_params)

    if @unsubscribe_feedback_form.valid? && Feedback.create(feedback_attributes)
      trigger_feedback_provided_event
      if current_jobseeker
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        render :confirmation
      end
    else
      render :new
    end
  end

  private

  def subscription_id
    params.require(:subscription_id)
  end

  def feedback_attributes
    unsubscribe_feedback_form_params.merge(feedback_type: "unsubscribe", subscription_id: subscription_id)
  end

  def unsubscribe_feedback_form_params
    params.require(:jobseekers_unsubscribe_feedback_form)
          .permit(:comment, :other_unsubscribe_reason_comment, :unsubscribe_reason)
  end
end
