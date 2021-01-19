class SubscriptionsController < ApplicationController
  include ParameterSanitiser

  def new
    @origin = origin_param if origin_param&.start_with?(%r{/\w})
    session[:subscription_origin] = @origin

    @subscription_form = SubscriptionForm.new(params[:search_criteria].present? ? search_criteria_params : email)
  end

  def create
    @subscription_form = SubscriptionForm.new(subscription_params)
    subscription = Subscription.new(@subscription_form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    recaptcha_is_valid = verify_recaptcha(model: subscription, action: "subscription")
    subscription.recaptcha_score = recaptcha_reply["score"] if recaptcha_is_valid && recaptcha_reply

    if recaptcha_is_valid && recaptcha_reply && invalid_recaptcha_score?
      redirect_to invalid_recaptcha_path(form_name: subscription.class.name.underscore.humanize)
    elsif @subscription_form.valid?
      subscription.save
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      trigger_subscription_event(:job_alert_subscription_created, subscription)

      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        @jobseeker_account_exists = Jobseeker.exists?(email: subscription.email)
        render :confirm
      end
    else
      render :new
    end
  end

  def edit
    @subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = SubscriptionForm.new(@subscription)
  end

  def update
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = SubscriptionForm.new(subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @subscription_form.valid?
      subscription.update(@subscription_form.job_alert_params)
      SubscriptionMailer.update(subscription.id).deliver_later
      trigger_subscription_event(:job_alert_subscription_updated, subscription)

      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        @jobseeker_account_exists = Jobseeker.exists?(email: subscription.email)
        render :confirm
      end
    else
      render :edit
    end
  end

  def unsubscribe
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription = SubscriptionPresenter.new(subscription)
    trigger_subscription_event(:job_alert_subscription_unsubscribed, subscription)
    subscription.unsubscribe
    @unsubscribe_feedback_form = UnsubscribeFeedbackForm.new
  end

  def unsubscribe_feedback
    @subscription = Subscription.find(token)
    @unsubscribe_feedback_form = UnsubscribeFeedbackForm.new(unsubscribe_feedback_params)

    if @unsubscribe_feedback_form.valid? && @subscription.unsubscribe_feedbacks.create(unsubscribe_feedback_params)
      if current_jobseeker
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        render :feedback_received
      end
    else
      render :unsubscribe
    end
  end

  private

  def trigger_subscription_event(type, subscription)
    request_event.trigger(
      type,
      subscription_identifier: StringAnonymiser.new(subscription.id),
      email_identifier: StringAnonymiser.new(subscription.email),
      recaptcha_score: subscription.recaptcha_score,
      frequency: subscription.frequency,
      search_criteria: subscription.search_criteria,
      origin: session.delete(:subscription_origin),
    )
  end

  def email
    ParameterSanitiser.call(params).permit(:email)
  end

  def origin_param
    params.permit(:origin)[:origin]
  end

  def search_criteria_params
    ParameterSanitiser.call(params.require(:search_criteria).permit(:keyword, :location, :radius, job_roles: [], phases: [], working_patterns: []))
  end

  def subscription_params
    ParameterSanitiser.call(params.require(:subscription_form).permit(:email, :frequency, :keyword, :location, :radius, job_roles: [], phases: [], working_patterns: []))
  end

  def token
    ParameterSanitiser.call(params).require(:id)
  end

  def unsubscribe_feedback_params
    ParameterSanitiser.call(params.require(:unsubscribe_feedback_form).permit(:reason, :other_reason, :additional_info))
  end
end
