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
    trust_size) AS proportion_of_schools_with_live_vacancies,
  number_of_users > 0 AS signed_up
FROM (
  SELECT
    trust_name,
    trust.id AS id,
    trust.uid AS uid,
    trust.data_ukprn AS ukprn,
    trust.address AS address,
    trust.town AS town,
    trust.county AS county,
    trust.postcode AS postcode,
    CAST(trust.created_at AS date) AS date_created,
    CAST(trust.updated_at AS date) AS date_updated,
    data_incorporated_on_open_date AS date_opened,
    data_companies_house_number AS companies_house_number,
    data_group_status AS status,
    COUNT(school.id) AS trust_size,
    (
    SELECT
      COUNT(user_id)
    FROM
      `teacher-vacancy-service.production_dataset.dsi_users` AS user
    WHERE
      CAST(user.organisation_uid AS STRING)=trust.uid ) AS number_of_users,
    (
    SELECT
      COUNT(user_id)
    FROM
      `teacher-vacancy-service.production_dataset.dsi_approvers` AS approver
    WHERE
      CAST(approver.organisation_uid AS STRING)=trust.uid ) AS number_of_approvers,
    #count trust-level vacancies published by this trust
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
    #count multi-school vacancies where at least 1 of the schools is part of this trust
    (
    SELECT
      COUNTIF(vacancy.number_of_organisations > 1)
    FROM
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
    ON
      vacancy.id=organisationvacancy.vacancy_id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_organisation` AS organisation
    ON
      organisation.id=organisationvacancy.organisation_id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
    ON
      organisation.id=schoolgroupmembership.school_id
    WHERE
      trust.id=schoolgroupmembership.school_group_id) AS multischool_vacancies_published,
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
    id,
    uid,
    ukprn,
    address,
    town,
    county,
    postcode,
    date_created,
    date_updated,
    date_opened,
    companies_house_number,
    status
  HAVING
    trust_size > 1 #exclude schools which aren't in trusts, and single academy trusts
    )
ORDER BY
  trust_size DESC
