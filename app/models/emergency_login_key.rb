class EmergencyLoginKey < ApplicationRecord
  belongs_to :user
  validates :not_valid_after, presence: true

  def valid?
    not_valid_after > Time.zone.now
  end
end
