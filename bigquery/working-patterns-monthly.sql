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
    COUNT(vacancy.id) AS number_of_vacancies,
    COUNTIF("full_time" IN UNNEST(vacancy.working_patterns)
      AND ARRAY_LENGTH(vacancy.working_patterns)=1) AS number_of_full_time_only_vacancies,
    COUNTIF("full_time" NOT IN UNNEST(vacancy.working_patterns)) AS number_of_vacancies_offering_flexible_working,
    COUNTIF("full_time" IN UNNEST(vacancy.working_patterns)) AS number_of_vacancies_offering_full_time,
    COUNTIF("part_time" IN UNNEST(vacancy.working_patterns)) AS number_of_vacancies_offering_part_time,
    COUNTIF("job_share" IN UNNEST(vacancy.working_patterns)) AS number_of_vacancies_offering_job_share,
    COUNTIF("compressed_hours" IN UNNEST(vacancy.working_patterns)) AS number_of_vacancies_offering_compressed_hours,
    COUNTIF("staggered_hours" IN UNNEST(vacancy.working_patterns)) AS number_of_vacancies_offering_staggered_hours,
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-08-01',DATE_TRUNC(CURRENT_DATE(),MONTH),INTERVAL 1 MONTH)) AS month
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
  ON
    DATE_TRUNC(vacancy.publish_on,MONTH)=month
  WHERE
    status != "draft"
    AND status != "trashed"
    AND status != "deleted"
  GROUP BY
    month )
ORDER BY
  month
