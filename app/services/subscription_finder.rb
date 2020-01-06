class SubscriptionFinder
  def initialize(params = {})
    @sanitised_params = params.each_pair do |key, value|
      params[key] = Sanitize.fragment(value)
    end
  end

  def exists?
    Subscription
      .where(email: @sanitised_params[:email],
             search_criteria: @sanitised_params[:search_criteria],
             frequency: @sanitised_params[:frequency])
      .exists?
  end
end
