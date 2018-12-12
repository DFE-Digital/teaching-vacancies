class SubscriptionsController < ApplicationController
  def new
    subscription = Subscription.new(search_criteria: search_criteria.to_json)
    @subscription = SubscriptionPresenter.new(subscription)
  end

  def create
    flash.clear
    subscription = Subscription.new(daily_subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    if Subscription.ongoing.exists?(email: daily_subscription_params[:email],
                                    search_criteria: daily_subscription_params[:search_criteria],
                                    frequency: daily_subscription_params[:frequency])
      flash[:error] = I18n.t('errors.subscriptions.already_exists')
    elsif @subscription.save
      flash[:notice] = I18n.t('messages.subscriptions.created')
      return render 'confirm'
    end

    render 'new'
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email, :reference, :search_criteria)
  end

  def daily_subscription_params
    subscription_params.merge(expires_on: 3.months.from_now,
                              frequency: :daily)
  end

  def search_criteria
    params.require(:search_criteria).permit(*VacancyFilters::AVAILABLE_FILTERS)
  end
end
