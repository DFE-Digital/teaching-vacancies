class EmergencyLoginKey < ApplicationRecord
  belongs_to :user
  validates :not_valid_after, presence: true

  def expired?
    Time.zone.now > not_valid_after
  end
end
