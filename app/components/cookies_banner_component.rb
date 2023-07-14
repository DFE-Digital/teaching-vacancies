class CookiesBannerComponent < ApplicationComponent
  attr_reader :accept_path, :reject_path, :preferences_path

  renders_one :body
  renders_one :actions

  def initialize(accept_path:, reject_path:, preferences_path:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge({ data: { controller: "cookies-banner" } }))

    @accept_path = accept_path
    @reject_path = reject_path
    @preferences_path = preferences_path
  end

  private

  def default_classes
    %w[cookies-banner-component]
  end
end
