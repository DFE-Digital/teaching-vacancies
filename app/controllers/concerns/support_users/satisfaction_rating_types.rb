module SupportUsers::SatisfactionRatingTypes
  SATISFACTION_RATING_TYPES = [
    {
      feedback_responses: %w[highly_satisfied somewhat_satisfied neither somewhat_dissatisfied highly_dissatisfied],
      feedback_type: :jobseeker_account,
      grouping_key: :rating,
      test_id: "satisfaction-rating-jobseekers",
    },
    {
      feedback_responses: %w[highly_satisfied somewhat_satisfied neither somewhat_dissatisfied highly_dissatisfied],
      feedback_type: :vacancy_publisher,
      grouping_key: :rating,
      test_id: "satisfaction-rating-hiring-staff",
    },
    {
      feedback_responses: %w[highly_satisfied somewhat_satisfied neither somewhat_dissatisfied highly_dissatisfied],
      feedback_type: :application,
      grouping_key: :rating,
      test_id: "satisfaction-rating-job-application",
    },
    {
      feedback_responses: [true, false],
      feedback_type: :job_alert,
      grouping_key: :relevant_to_user,
      test_id: "satisfaction-rating-job-alerts",
    },
    {
      feedback_responses: %w[job_found circumstances_change not_relevant other_reason],
      feedback_type: :unsubscribe,
      grouping_key: :unsubscribe_reason,
      test_id: "job-alert-unsubscribe-reason",
    },
    {
      feedback_responses: %w[too_many_emails not_getting_any_value not_looking_for_job other_close_account_reason],
      feedback_type: :close_account,
      grouping_key: :close_account_reason,
      test_id: "close-account-reason",
    },
  ].freeze
end
