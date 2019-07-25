class GeneralFeedback < ApplicationRecord
  include Auditor::Model

  enum visit_purpose: %i[other_purpose find_teaching_job list_teaching_job]

  validates :visit_purpose, presence: true
  validates :visit_purpose_comment, length: { maximum: 1200 }, if: :visit_purpose_comment?
  validates :comment, length: { maximum: 1200 }, if: :comment?

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      visit_purpose,
      visit_purpose_comment,
      rating,
      comment,
      created_at.to_s
    ]
  end
end
