class SubscriptionFinder
  def initialize(params = {})
    @email = params[:email]
    @search_criteria = params[:search_criteria]
    @frequency = params[:frequency]
  end

  def exists?
    Subscription.ongoing.exists?(email: @email,
                                 search_criteria: @search_criteria,
                                 frequency: @frequency)
  end
end
