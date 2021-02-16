class AbTest::CookiesBannerComponent < ViewComponent::Base
  attr_reader :create_path, :preferences_path

  def initialize(create_path:, preferences_path:)
    @create_path = create_path
    @preferences_path = preferences_path
  end
end
