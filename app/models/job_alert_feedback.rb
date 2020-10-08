class JobAlertFeedback < ApplicationRecord
  belongs_to :subscription

  validates :comment, length: { maximum: 1200 }, if: :comment?
  validates :relevant_to_user, presence: true
  validates :search_criteria, presence: true
  # Not using ActiveRecord association such as has_and_belongs_to_many for vacancy_ids,
  # as this data is for BigQuery (Performance Analysis) to use, not Rails.
  validates :vacancy_ids, presence: true
end
