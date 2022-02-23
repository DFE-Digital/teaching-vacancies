class SupportUser < ApplicationRecord
  devise :timeoutable
  self.timeout_in = 60.minutes # Overrides default Devise configuration
end
