class Jobseekers::SubscriptionsController < Jobseekers::BaseController
  helper_method :sort, :sort_form, :subscriptions

  private

  def sort
    @sort ||= Jobseekers::SubscriptionSort.new.update(column: params[:sort_column])
  end

  def sort_form
    @sort_form ||= SortForm.new(sort.column)
  end

  def subscriptions
    @subscriptions ||= Subscription.active.where(email: current_jobseeker.email).order(sort.column => sort.order)
                                   .map { |subscription| SubscriptionPresenter.new(subscription) }
  end
end
