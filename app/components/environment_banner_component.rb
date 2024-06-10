class EnvironmentBannerComponent < ApplicationComponent
  include FailSafe

  def initialize(classes: [], html_attributes: {})
    super
  end

  def render?
    return false if Rails.configuration.app_role.unknown?
    return false if Rails.configuration.app_role.production?

    true
  end
end
