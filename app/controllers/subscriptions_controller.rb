class SubscriptionsController < ApplicationController
  include ParameterSanitiser

  def new
    @origin = origin_param[:origin]
    @subscription_form = SubscriptionForm.new(params[:search_criteria].present? ? search_criteria_params : email)
    Auditor::Audit.new(nil, "subscription.alert.new", current_publisher_oid).log_without_association
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
      Auditor::Audit.new(subscription, "subscription.#{subscription.frequency}_alert.create", current_publisher_oid).log
      AuditSubscriptionCreationJob.perform_later(@subscription.to_row)
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        render :confirm
      end
    else
      render :new
    end
  end

  def edit
    @subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = SubscriptionForm.new(@subscription)
    Auditor::Audit.new(@subscription, "subscription.alert.edit", current_publisher_oid).log_without_association
  end

  def update
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription_form = SubscriptionForm.new(subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if @subscription_form.valid?
      subscription.update(@subscription_form.job_alert_params)
      Auditor::Audit.new(subscription, "subscription.update", current_publisher_oid).log

      if jobseeker_signed_in?
        redirect_to jobseekers_subscriptions_path, success: t(".success")
      else
        SubscriptionMailer.update(subscription.id).deliver_later
        render :confirm_update
      end
    else
      render :edit
    end
  end

  def unsubscribe
    subscription = Subscription.find_and_verify_by_token(token)
    @subscription = SubscriptionPresenter.new(subscription)
    Auditor::Audit.new(subscription, "subscription.#{subscription.frequency}_alert.delete", current_publisher_oid).log
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

  def email
    ParameterSanitiser.call(params).permit(:email)
  end

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

  def unsubscribe_feedback_params
    ParameterSanitiser.call(params.require(:unsubscribe_feedback_form).permit(:reason, :other_reason, :additional_info))
  end
end
