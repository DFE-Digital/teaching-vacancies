class SubscriptionFinder
  include ParameterSanitiser

  def initialize(params = {})
    @sanitised_params = ParameterSanitiser.call(params)
  end

  def exists?
    Subscription
      .where(email: @sanitised_params[:email],
             search_criteria: @sanitised_params[:search_criteria],
             frequency: @sanitised_params[:frequency])
      .exists?
  end
end
