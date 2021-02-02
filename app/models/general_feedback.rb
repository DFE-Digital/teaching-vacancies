class GeneralFeedback < ApplicationRecord
  enum visit_purpose: { find_teaching_job: 1, list_teaching_job: 2, other_purpose: 0 }
  enum user_participation_response: { interested: 0, not_interested: 1 }

  validates :visit_purpose, presence: true

  validates :visit_purpose_comment, length: { maximum: 1200 }, if: :visit_purpose_comment?
end
