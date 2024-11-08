class ApiClient < ApplicationRecord
  before_create :generate_api_key

  def generate_api_key
    self.api_key = SecureRandom.hex(20)
  end

  def rotate_api_key!
    update(api_key: SecureRandom.hex(20), last_rotated_at: Time.current)
  end
end
