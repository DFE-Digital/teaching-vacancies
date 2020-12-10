class Jobseekers::SubscriptionsController < Jobseekers::ApplicationController
  def index
    @subscriptions = Subscription.active.where(email: current_jobseeker.email)
                                        .map { |subscription| SubscriptionPresenter.new(subscription) }
  end
end
