class Publisher < ApplicationRecord
  has_many :emergency_login_keys

  def accepted_terms_and_conditions?
    accepted_terms_at.present?
  end
end
