SELECT
  feedback.id,
  reason,
  other_reason,
  additional_info,
  created_at,
  search_criteria,
  location,
  radius,
  working_patterns,
  newly_qualified_teacher,
  education_phases,
  subject,
  keyword,
FROM
  `teacher-vacancy-service.production_dataset.feb20_unsubscribefeedback` AS feedback
LEFT JOIN
  `teacher-vacancy-service.production_dataset.job_alert` AS job_alert
ON
  feedback.subscription_id=job_alert.id
ORDER BY
  created_at DESC
