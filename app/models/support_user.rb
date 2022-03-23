class SupportUser < ApplicationRecord
  devise :timeoutable
  self.timeout_in = 60.minutes # Overrides default Devise configuration

  def papertrail_display_name
    t("support_users.papertrail_display_name", first_name: given_name, last_name: family_name)
  end
end
