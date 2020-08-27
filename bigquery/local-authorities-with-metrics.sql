SELECT
  LA.*,
  SAFE_DIVIDE(schools_signed_up,
    schools_in_scope) AS proportion_of_schools_signed_up,
  SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_year,
    schools_in_scope) AS proportion_of_schools_that_published_vacancies_in_the_last_year,
  SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_quarter,
    schools_in_scope) AS proportion_of_schools_that_published_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(schools_that_published_vacancies,
    schools_in_scope) AS proportion_of_schools_that_published_vacancies,
  SAFE_DIVIDE(schools_with_live_vacancies,
    schools_in_scope) AS proportion_of_schools_with_live_vacancies,
  LA_access.access
FROM (
  SELECT
    local_authority,
    COUNT(urn) AS schools_in_scope,
    COUNTIF(signed_up IS TRUE) AS schools_signed_up,
    COUNTIF(vacancies_published_in_the_last_year>0) AS schools_that_published_vacancies_in_the_last_year,
    COUNTIF(vacancies_published_in_the_last_quarter>0) AS schools_that_published_vacancies_in_the_last_quarter,
    COUNTIF(vacancies_published>0) AS schools_that_published_vacancies,
    COUNTIF(vacancies_currently_live>0) AS schools_with_live_vacancies
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics`
  GROUP BY
    local_authority ) AS LA
LEFT JOIN
  `teacher-vacancy-service.production_dataset.LA_access_from_google_sheet` AS LA_access
ON
  LA.local_authority=LA_access.LA
ORDER BY
  local_authority ASC
