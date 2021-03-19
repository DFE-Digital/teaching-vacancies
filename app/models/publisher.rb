class Publisher < ApplicationRecord
  has_many :publisher_preferences, dependent: :destroy
  has_many :emergency_login_keys

  has_many :organisation_publishers, dependent: :destroy
  has_many :organisations, through: :organisation_publishers
  accepts_nested_attributes_for :organisation_publishers

  devise :omniauthable, :timeoutable, omniauth_providers: %i[dfe]
  self.timeout_in = 60.minutes # Overrides default Devise configuration

  def accepted_terms_and_conditions?
    accepted_terms_at.present?
  end
end
