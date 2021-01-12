class Jobseekers::SubscriptionsController < Jobseekers::ApplicationController
  def index
    @sort = Jobseekers::SubscriptionSort.new.update(column: params[:sort_column])
    @sort_form = SortForm.new(@sort.column)
    @subscriptions = Subscription.active.where(email: current_jobseeker.email)
                                        .order(@sort.column => @sort.order)
                                        .map { |subscription| SubscriptionPresenter.new(subscription) }
  end
end
