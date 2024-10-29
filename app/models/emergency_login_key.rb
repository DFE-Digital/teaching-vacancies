class EmergencyLoginKey < ApplicationRecord
  self.ignored_columns += %w[publisher_id]
  belongs_to :owner, polymorphic: true
  validates :not_valid_after, presence: true

  def expired?
    Time.current > not_valid_after
  end
end
