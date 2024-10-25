class JobseekerEmergencyLoginKey < ApplicationRecord
  belongs_to :jobseeker
  validates :not_valid_after, presence: true

  def expired?
    Time.current > not_valid_after
  end
end