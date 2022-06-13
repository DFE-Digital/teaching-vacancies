class CookiesBannerComponent < ApplicationComponent
  attr_reader :create_path, :reject_path, :preferences_path

  renders_one :body
  renders_one :actions

  def initialize(create_path:, reject_path:, preferences_path:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @create_path = create_path
    @reject_path = reject_path
    @preferences_path = preferences_path
  end

  private

  def default_attributes
    { class: %w[cookies-banner-component] }
  end
end
