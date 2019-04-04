class GeneralFeedback < ApplicationRecord
  validates :rating, presence: true

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      rating,
      comment,
      created_at.to_s
    ]
  end
end
