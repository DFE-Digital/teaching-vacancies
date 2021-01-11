class JobAlertFeedback < ApplicationRecord
  include Auditor::Model

  serialize :search_criteria, JsonbSerializer

  belongs_to :subscription

  validates :comment, length: { maximum: 1200 }, if: :comment?
  validates :search_criteria, presence: true

  # `presence` uses 'blank?', which returns `true` if relevant_to_user is `false`.
  validates :relevant_to_user, inclusion: { in: [true, false] }

  # Not using ActiveRecord association such as has_and_belongs_to_many for vacancy_ids,
  # as this data is for BigQuery (Performance Analysis) to use, not Rails.
  validates :vacancy_ids, presence: true
end
