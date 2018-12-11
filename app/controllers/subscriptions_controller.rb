class SubscriptionsController < ApplicationController
  def new
    subscription = Subscription.new(search_criteria: search_criteria.to_json)
    @subscription = SubscriptionPresenter.new(subscription)
  end

  def create
    subscription = Subscription.new(subscription_params)
    @subscription = SubscriptionPresenter.new(subscription)

    render 'new' unless @subscription.valid?
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email, :reference, :search_criteria)
  end

  def search_criteria
    params.require(:search_criteria).permit(*VacancyFilters::AVAILABLE_FILTERS)
  end
end
