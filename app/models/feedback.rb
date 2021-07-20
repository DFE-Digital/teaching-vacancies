class Feedback < ApplicationRecord
  encrypts :email, migrating: true

  enum feedback_type: { jobseeker_account: 0, general: 1, job_alert: 2, unsubscribe: 3, vacancy_publisher: 4, application: 5, close_account: 6 }
  enum user_participation_response: { interested: 0, uninterested: 1 }
  enum rating: { highly_satisfied: 0, somewhat_satisfied: 1, neither: 2, somewhat_dissatisfied: 3, highly_dissatisfied: 4 }
  enum unsubscribe_reason: { not_relevant: 0, job_found: 1, circumstances_change: 2, other_reason: 3 }
  enum visit_purpose: { find_teaching_job: 1, list_teaching_job: 2, other_purpose: 0 }
  enum close_account_reason: { too_many_emails: 0, not_getting_any_value: 1, not_looking_for_job: 2, other_close_account_reason: 3 }

  validate :feedback_type, :presence
end
