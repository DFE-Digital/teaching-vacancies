class EnvironmentBannerComponent < GovukComponent::Base
  include FailSafe

  def initialize(classes: [], html_attributes: {})
    super(classes:, html_attributes:)
  end

  def render?
    return false if Rails.configuration.app_role.unknown?
    return false if Rails.configuration.app_role.production?

    true
  end
end
