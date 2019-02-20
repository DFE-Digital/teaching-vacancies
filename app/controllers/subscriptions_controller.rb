class SubscriptionsController < ApplicationController
  include ParameterSanitiser

  before_action :check_feature_flag, except: :unsubscribe

  def new
    subscription = Subscription.new(search_criteria: search_criteria.to_json)
    @subscription = SubscriptionPresenter.new(subscription)
    Auditor::Audit.new(nil, 'subscription.daily_alert.new', nil).log_without_association
  end

  def create
    flash.clear
    subscription = Subscription.new(daily_subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if SubscriptionFinder.new(daily_subscription_params).exists?
      flash[:error] = I18n.t('errors.subscriptions.already_exists')
    elsif subscription.save
      Auditor::Audit.new(subscription, 'subscription.daily_alert.create', nil).log
      SubscriptionMailer.confirmation(subscription.id).deliver_later
      return render 'confirm'
    end

    render 'new'
  end

  def unsubscribe
    token = ParameterSanitiser.call(params).require(:subscription_id)
    @subscription = Subscription.find_and_verify_by_token(token)
    @subscription.delete
    Auditor::Audit.new(@subscription, 'subscription.daily_alert.delete', nil).log
  end

  private

  def subscription_params
    ParameterSanitiser.call(
      params.require(:subscription)
    ).permit(:email, :reference, :search_criteria)
  end

  def daily_subscription_params
    subscription_params.merge(expires_on: 3.months.from_now,
                              frequency: :daily)
  end

  def search_criteria
    params.require(:search_criteria).permit(*VacancyFilters::AVAILABLE_FILTERS)
  end

  def check_feature_flag
    not_found unless EmailAlertsFeature.enabled?
  end
end
