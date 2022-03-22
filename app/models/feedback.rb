class Feedback < ApplicationRecord
  JOB_ALERT_CATEGORIES = {
    insufficient_job_alerts: "Insufficient job alerts",
    international_teachers: "International teachers",
    jobseeker_requests: "Jobseeker requests / qual feedback",
    positive: "Positive",
    role_not_relevant: "Role not relevant",
    role_not_relevant_support: "Role not relevant - support roles",
    search_and_filter: "Search and filter preferences",
    short_deadline: "Short time to deadline",
    unsubscribe_reason: "Reason for unsubscribing",
    usability: "Usability",
    wrong_location: "Wrong location / commute distance",
  }.freeze

  NON_JOB_ALERT_CATEGORIES = {
    applications: "Applications",
    comms_advertising: "Comms advertising",
    document_uploads: "Document uploads",
    filters: "Filters / search",
    formatting: "Formatting",
    general_search: "General search",
    international_candidates: "International candidates",
    jobseeker_requests: "Jobseeker requests (misc)",
    listing_vacancies: "Listing vacancies",
    location: "Location / search",
    positive: "Positive feedback",
    reporting: "Reporting / stats / performance",
    scope: "Scope",
    send: "SEND",
    usability: "Usability / access",
    visual_identity: "Visual identity",
  }.freeze

  enum feedback_type: { jobseeker_account: 0, general: 1, job_alert: 2, unsubscribe: 3, vacancy_publisher: 4, application: 5, close_account: 6 }
  enum user_participation_response: { interested: 0, uninterested: 1 }
  enum rating: { highly_satisfied: 0, somewhat_satisfied: 1, neither: 2, somewhat_dissatisfied: 3, highly_dissatisfied: 4 }
  enum unsubscribe_reason: { not_relevant: 0, job_found: 1, circumstances_change: 2, other_reason: 3 }
  enum visit_purpose: { find_teaching_job: 1, list_teaching_job: 2, other_purpose: 0 }
  enum close_account_reason: { too_many_emails: 0, not_getting_any_value: 1, not_looking_for_job: 2, other_close_account_reason: 3 }

  validate :feedback_type, :presence

  scope :job_alerts, -> { where(feedback_type: :job_alert) }
  scope :except_job_alerts, -> { where.not(feedback_type: :job_alert) }
end
