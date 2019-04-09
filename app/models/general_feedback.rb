class GeneralFeedback < ApplicationRecord
  include Auditor::Model

  enum visit_purpose: %i[other_purpose find_teaching_job list_teaching_job]

  validates :visit_purpose, presence: true
  validates :rating, presence: true

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      visit_purpose,
      visit_purpose_comment,
      rating,
      comment,
      email,
      created_at.to_s
    ]
  end
end
