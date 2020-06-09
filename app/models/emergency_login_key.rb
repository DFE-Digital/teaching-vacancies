class EmergencyLoginKey < ApplicationRecord
  belongs_to :user
  validates :not_valid_after, presence: true
end
