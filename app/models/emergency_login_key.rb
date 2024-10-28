class EmergencyLoginKey < ApplicationRecord
  belongs_to :owner, polymorphic: true
  validates :not_valid_after, presence: true

  def expired?
    Time.current > not_valid_after
  end
end
