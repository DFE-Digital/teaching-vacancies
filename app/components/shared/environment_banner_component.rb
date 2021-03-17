class Shared::EnvironmentBannerComponent < GovukComponent::Base
  def render?
    return false if Rails.configuration.app_role.unknown?
    return false if Rails.configuration.app_role.production?

    true
  end
end
