class SubscriptionsController < ApplicationController
  include ParameterSanitiser

  def new
    @origin = origin_param[:origin]
    @subscription_form = SubscriptionForm.new(search_criteria_params)
    Auditor::Audit.new(nil, "subscription.alert.new", current_session_id).log_without_association
  end

  def create
    @subscription_form = SubscriptionForm.new(subscription_params)
    subscription = Subscription.new(@subscription_form.job_alert_params)
    @subscription = SubscriptionPresenter.new(subscription)

    recaptcha_is_valid = verify_recaptcha(model: subscription, action: "subscription")
    subscription.recaptcha_score = recaptcha_reply["score"] if recaptcha_is_valid && recaptcha_reply

    if @subscription_form.valid?
      subscription.save
      Auditor::Audit.new(subscription, "subscription.#{subscription.frequency}_alert.create", current_session_id).log
      AuditSubscriptionCreationJob.perform_later(@subscription.to_row)
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      render :confirm
    else
      render :new
    end
  end

  def edit
    @subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = SubscriptionForm.new(@subscription)
    Auditor::Audit.new(@subscription, "subscription.alert.edit", current_session_id).log_without_association
  end

  def update
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = SubscriptionForm.new(subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @subscription_form.valid?
      subscription.update(@subscription_form.job_alert_params)
      Auditor::Audit.new(subscription, "subscription.update", current_session_id).log
      SubscriptionMailer.update(subscription.id).deliver_later
      render :confirm_update
    else
      render :edit
    end
  end

  def unsubscribe
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription = SubscriptionPresenter.new(subscription)
    Auditor::Audit.new(subscription, "subscription.#{subscription.frequency}_alert.delete", current_session_id).log
    subscription.unsubscribe
  end

private

  def origin_param
    params.permit(:origin)
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
end
