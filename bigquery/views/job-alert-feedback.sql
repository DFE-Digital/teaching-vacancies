SELECT
  id,
  relevant_to_user,
  comment,
  search_criteria,
  ARRAY_TO_STRING(ARRAY(
    SELECT
      CONCAT("https://teaching-vacancies.service.gov.uk/jobs/",vacancy.slug) AS vacancy_url
    FROM
      UNNEST(REGEXP_EXTRACT_ALL(vacancy_ids, "\"(.+?)\"")) AS vacancy_id
    JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    ON
      vacancy_id=vacancy.id),", ") AS vacancy_urls
FROM
  `teacher-vacancy-service.production_dataset.feb20_jobalertfeedback` AS feedback
WHERE
  recaptcha_score IS NULL
  OR recaptcha_score > 0.5
