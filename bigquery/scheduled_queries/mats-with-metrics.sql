SELECT *,
SAFE_DIVIDE(schools_signed_up,trust_size) AS proportion_of_schools_signed_up,
SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_year,trust_size) AS proportion_of_schools_that_published_vacancies_in_the_last_year,
SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_quarter,trust_size) AS proportion_of_schools_that_published_vacancies_in_the_last_quarter,
SAFE_DIVIDE(schools_that_published_vacancies,trust_size) AS proportion_of_schools_that_published_vacancies,
SAFE_DIVIDE(schools_with_live_vacancies,trust_size) AS proportion_of_schools_with_live_vacancies
FROM
(
SELECT
  trust_name,
  MAX(academies_in_trust) AS trust_size,
  COUNTIF(signed_up IS TRUE) AS schools_signed_up,
  COUNTIF(vacancies_published_in_the_last_year>0) AS schools_that_published_vacancies_in_the_last_year,
  COUNTIF(vacancies_published_in_the_last_quarter>0) AS schools_that_published_vacancies_in_the_last_quarter,
  COUNTIF(vacancies_published>0) AS schools_that_published_vacancies,
  COUNTIF(vacancies_currently_live>0) AS schools_with_live_vacancies
FROM
  `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics`
WHERE academies_in_trust > 1 #exclude schools which aren't in trusts, and single academy trusts
GROUP BY
  trust_name,academies_in_trust
)
ORDER BY trust_size DESC
