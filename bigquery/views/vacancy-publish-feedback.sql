SELECT
  feedback.id AS feedback_id,
  feedback.comment AS feedback_comment,
  feedback.created_at AS feedback_created_at,
  feedback.email AS feedback_email,
  feedback.user_participation_response AS feedback_user_participation_response,
  vacancy.*,
  CONCAT("https://teaching-vacancies.service.gov.uk/jobs/",vacancy.slug) AS vacancy_url
FROM
  `teacher-vacancy-service.production_dataset.feb20_vacancypublishfeedback` AS feedback
LEFT JOIN
  `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
ON
  feedback.vacancy_id=vacancy.id
