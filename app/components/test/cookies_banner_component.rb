class Test::CookiesBannerComponent < ViewComponent::Base
  attr_accessor :utm_parameters

  def initialize(utm_parameters:)
    @utm_parameters = utm_parameters
  end
end
