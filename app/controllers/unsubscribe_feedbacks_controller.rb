class UnsubscribeFeedbacksController < ApplicationController
  def new
    subscription = Subscription.find(subscription_id)
    @subscription = SubscriptionPresenter.new(subscription)
    @unsubscribe_feedback_form = Jobseekers::UnsubscribeFeedbackForm.new
  end

  def create
    @subscription = Subscription.find(subscription_id)
    @unsubscribe_feedback_form = Jobseekers::UnsubscribeFeedbackForm.new(unsubscribe_feedback_params)

    if @unsubscribe_feedback_form.valid? && @subscription.unsubscribe_feedbacks.create(unsubscribe_feedback_params)
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
    ParameterSanitiser.call(params).require(:subscription_id)
  end

  def unsubscribe_feedback_params
    ParameterSanitiser.call(params).require(:jobseekers_unsubscribe_feedback_form).permit(:reason, :other_reason, :additional_info)
  end
end
