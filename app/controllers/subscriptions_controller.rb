class SubscriptionsController < ApplicationController
  include ParameterSanitiser

  def new
    subscription = Subscription.new(search_criteria: search_criteria_params.to_json)
    @subscription = SubscriptionPresenter.new(subscription)
    Auditor::Audit.new(nil, 'subscription.alert.new', current_session_id).log_without_association
  end

  def create
    subscription = Subscription.new(subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    recaptcha_valid = verify_recaptcha(model: subscription, action: 'subscription')
    subscription.recaptcha_score = recaptcha_reply['score'] if recaptcha_valid && recaptcha_reply

    if SubscriptionFinder.new(subscription_params).exists?
      flash.now[:error] = I18n.t('errors.subscriptions.already_exists')
    elsif subscription.save
      Auditor::Audit.new(subscription, "subscription.#{subscription.frequency}_alert.create", current_session_id).log
      AuditSubscriptionCreationJob.perform_later(@subscription.to_row)
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      return render :confirm
    end

    render :new
  end

  def unsubscribe
    token = ParameterSanitiser.call(params).require(:subscription_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    Auditor::Audit.new(@subscription, "subscription.#{@subscription.frequency}_alert.delete", current_session_id).log
    @subscription.delete
  end

private

  def subscription_params
    ParameterSanitiser.call(params.require(:subscription)).permit(:email, :frequency, :search_criteria)
  end

  def search_criteria_params
    params.require(:search_criteria)
          .permit(:keyword, :location, :location_category, :radius, :jobs_sort,
                  job_roles: [], phases: [], working_patterns: [])
  end
end
