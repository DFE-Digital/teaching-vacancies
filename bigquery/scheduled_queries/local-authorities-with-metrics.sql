SELECT
  *,
  SAFE_DIVIDE(schools_signed_up,
    schools_maintained_by_la) AS proportion_of_schools_signed_up,
  SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_year,
    schools_maintained_by_la) AS proportion_of_schools_that_published_vacancies_in_the_last_year,
  SAFE_DIVIDE(schools_that_published_vacancies_in_the_last_quarter,
    schools_maintained_by_la) AS proportion_of_schools_that_published_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(schools_that_published_vacancies,
    schools_maintained_by_la) AS proportion_of_schools_that_published_vacancies,
  SAFE_DIVIDE(schools_with_live_vacancies,
    schools_maintained_by_la) AS proportion_of_schools_with_live_vacancies,
  number_of_la_level_users > 0 AS signed_up,
  number_of_la_access_workaround_users > 0 AS using_la_access_workaround
FROM (
  SELECT
    LA.name AS name,
    LA.id AS id,
    LA.local_authority_code AS code,
    CAST(LA.created_at AS date) AS date_created,
    CAST(LA.updated_at AS date) AS date_updated,
    LA.data_closed_date AS date_closed,
    data_incorporated_on_open_date AS date_opened,
    data_companies_house_number AS companies_house_number,
  IF
    (LA.created_at IS NOT NULL
      AND LA.created_at < CURRENT_DATETIME()
      AND (LA.data_closed_date IS NULL
        OR LA.data_closed_date > CURRENT_DATE()),
      "Open",
      "Closed") AS status,
    COUNT(school.id) AS schools_maintained_by_la,
    (
    SELECT
      COUNT(user_id)
    FROM
      `teacher-vacancy-service.production_dataset.dsi_users` AS user
    WHERE
      CAST(user.la_code AS STRING)=LA.local_authority_code ) AS number_of_la_level_users,
    (
    SELECT
      COUNT(user_id)
    FROM
      `teacher-vacancy-service.production_dataset.dsi_approvers` AS approver
    WHERE
      CAST(approver.la_code AS STRING)=LA.local_authority_code ) AS number_of_la_level_approvers,
    (
    SELECT
      COUNT(DISTINCT
      IF
        (number_of_schools_user_has_access_to > 1,
          email,
          NULL))
    FROM (
      SELECT
        email,
        COUNT(DISTINCT school_urn) AS number_of_schools_user_has_access_to
      FROM
        `teacher-vacancy-service.production_dataset.dsi_users` AS user
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.school` AS school
      ON
        CAST(user.school_urn AS STRING)=school.urn
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
      ON
        school.id=schoolgroupmembership.school_id
      WHERE
        schoolgroupmembership.school_group_id=LA.id
      GROUP BY
        user.email )) AS number_of_la_access_workaround_users,
    #count vacancies published by this trust using LA level access
    (
    SELECT
      COUNT(vacancy.id)
    FROM
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    WHERE
      LA.id=vacancy.publisher_organisation_id) AS vacancies_published_using_LA_access,
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
      LA.id=organisationvacancy.organisation_id) AS LA_level_vacancies_published,
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
      LA.id=schoolgroupmembership.school_group_id) AS multischool_vacancies_published,
    COUNTIF(signed_up IS TRUE) AS schools_signed_up,
    COUNTIF(vacancies_published_in_the_last_year>0) AS schools_that_published_vacancies_in_the_last_year,
    COUNTIF(vacancies_published_in_the_last_quarter>0) AS schools_that_published_vacancies_in_the_last_quarter,
    COUNTIF(vacancies_published>0) AS schools_that_published_vacancies,
    COUNTIF(vacancies_currently_live>0) AS schools_with_live_vacancies
  FROM
    `teacher-vacancy-service.production_dataset.feb20_organisation` AS LA
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
  ON
    LA.id=schoolgroupmembership.school_group_id
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics` AS school
  ON
    schoolgroupmembership.school_id=school.id
  WHERE
    group_type = "local_authority"
  GROUP BY
    name,
    id,
    local_authority_code,
    date_created,
    date_updated,
    date_opened,
    date_closed,
    companies_house_number,
    status )
ORDER BY
  name ASC
