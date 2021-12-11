class Jobseekers::SubscriptionsController < Jobseekers::BaseController
  helper_method :sort, :subscriptions

  private

  def sort
    @sort ||= Jobseekers::SubscriptionSort.new.update(sort_by: params[:sort_by])
  end

  def subscriptions
    @subscriptions ||= Subscription.active.where(email: current_jobseeker.email).order(sort.by => sort.order)
                                   .map { |subscription| SubscriptionPresenter.new(subscription) }
  end
end
