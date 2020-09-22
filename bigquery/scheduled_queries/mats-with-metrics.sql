SELECT
  *,
  SAFE_DIVIDE(schools_signed_up,
    trust_size) AS proportion_of_schools_signed_up,
  SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_year,
    trust_size) AS proportion_of_schools_that_published_vacancies_in_the_last_year,
  SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_quarter,
    trust_size) AS proportion_of_schools_that_published_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(schools_that_published_vacancies,
    trust_size) AS proportion_of_schools_that_published_vacancies,
  SAFE_DIVIDE(schools_with_live_vacancies,
    trust_size) AS proportion_of_schools_with_live_vacancies
FROM (
  SELECT
    trust_name,
    trust.id AS id,
    COUNT(school.id) AS trust_size,
    (
    SELECT
      COUNTIF(schoolgroup_level)
    FROM
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
    ON
      vacancy.id=organisationvacancy.vacancy_id
    WHERE
      trust.id=organisationvacancy.organisation_id) AS trust_level_vacancies_published,
    COUNTIF(signed_up IS TRUE) AS schools_signed_up,
    COUNTIF(vacancies_published_in_the_last_year>0) AS schools_that_published_vacancies_in_the_last_year,
    COUNTIF(vacancies_published_in_the_last_quarter>0) AS schools_that_published_vacancies_in_the_last_quarter,
    COUNTIF(vacancies_published>0) AS schools_that_published_vacancies,
    COUNTIF(vacancies_currently_live>0) AS schools_with_live_vacancies
  FROM
    `teacher-vacancy-service.production_dataset.feb20_organisation` AS trust
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
  ON
    trust.id=schoolgroupmembership.school_group_id
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics` AS school
  ON
    schoolgroupmembership.school_id=school.id
  WHERE
    data_group_type = "Multi-academy trust"
  GROUP BY
    trust_name,
    id
  HAVING
    trust_size > 1 #exclude schools which aren't in trusts, and single academy trusts
    )
ORDER BY
  trust_size DESC
