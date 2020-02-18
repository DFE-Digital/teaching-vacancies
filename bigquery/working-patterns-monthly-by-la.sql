SELECT
  *,
  SAFE_DIVIDE(number_of_full_time_only_vacancies,
    number_of_vacancies) AS proportion_of_full_time_only_vacancies,
  SAFE_DIVIDE(number_of_vacancies_offering_flexible_working,
    number_of_vacancies) AS proportion_of_vacancies_offering_flexible_working,
  SAFE_DIVIDE(number_of_vacancies_offering_full_time,
    number_of_vacancies) AS proportion_of_vacancies_offering_full_time,
  SAFE_DIVIDE(number_of_vacancies_offering_part_time,
    number_of_vacancies) AS proportion_of_vacancies_offering_part_time,
  SAFE_DIVIDE(number_of_vacancies_offering_job_share,
    number_of_vacancies) AS proportion_of_vacancies_offering_job_share,
  SAFE_DIVIDE(number_of_vacancies_offering_compressed_hours,
    number_of_vacancies) AS proportion_of_vacancies_offering_compressed_hours,
  SAFE_DIVIDE(number_of_vacancies_offering_staggered_hours,
    number_of_vacancies) AS proportion_of_vacancies_offering_staggered_hours
FROM (
  SELECT
    month,
    school.local_authority AS local_authority,
    COUNT(vacancy.id) AS number_of_vacancies,
    COUNTIF(vacancy.working_patterns="[\"full_time\"]") AS number_of_full_time_only_vacancies,
    COUNTIF(vacancy.working_patterns!="[\"full_time\"]") AS number_of_vacancies_offering_flexible_working,
    COUNTIF(vacancy.working_patterns LIKE "%full_time%") AS number_of_vacancies_offering_full_time,
    COUNTIF(vacancy.working_patterns LIKE "%part_time%") AS number_of_vacancies_offering_part_time,
    COUNTIF(vacancy.working_patterns LIKE "%job_share%") AS number_of_vacancies_offering_job_share,
    COUNTIF(vacancy.working_patterns LIKE "%compressed_hours%") AS number_of_vacancies_offering_compressed_hours,
    COUNTIF(vacancy.working_patterns LIKE "%compressed_hours%") AS number_of_vacancies_offering_staggered_hours,
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-08-01',DATE_TRUNC(CURRENT_DATE(),MONTH),INTERVAL 1 MONTH)) AS month
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.vacancy` AS vacancy
  ON
    DATE_TRUNC(PARSE_DATE("%e %B %E4Y",
        vacancy.publish_on),MONTH)=month
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.school` AS school
  ON
    vacancy.school_id=school.id
  WHERE
    status != "draft"
    AND status != "trashed"
    AND status != "deleted"
  GROUP BY
    month,
    local_authority )
ORDER BY
  month
