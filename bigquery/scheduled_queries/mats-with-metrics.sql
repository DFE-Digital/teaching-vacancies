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
  number_of_users > 0 AS signed_up,
  number_of_mat_access_workaround_users > 0 AS using_mat_access_workaround,
  CASE
    WHEN trust_size < 2 THEN "0-1"
    WHEN trust_size < 6 THEN "2-5"
    WHEN trust_size < 11 THEN "6-10"
    WHEN trust_size < 21 THEN "11-20"
  ELSE
  "21+"
END
  AS size_bracket,
FROM (
  SELECT
    MAT.name AS trust_name,
    MAT.id AS id,
    MAT.uid AS uid,
    MAT.data_ukprn AS ukprn,
    MAT.address AS address,
    MAT.town AS town,
    MAT.county AS county,
    MAT.postcode AS postcode,
    CAST(MAT.created_at AS date) AS date_created,
    CAST(MAT.updated_at AS date) AS date_updated,
    MAT.data_closed_date AS date_closed,
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
      CAST(user.organisation_uid AS STRING)=MAT.uid ) AS number_of_users,
    (
    SELECT
      COUNT(user_id)
    FROM
      `teacher-vacancy-service.production_dataset.dsi_approvers` AS approver
    WHERE
      CAST(approver.organisation_uid AS STRING)=MAT.uid ) AS number_of_approvers,
    (
    SELECT
      COUNT(
      IF
        (number_of_schools_user_has_access_to > 1,
          email,
          NULL))
    FROM (
      SELECT
        email,
        COUNT(school_urn) AS number_of_schools_user_has_access_to
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
        schoolgroupmembership.school_group_id=MAT.id
      GROUP BY
        user.email )) AS number_of_mat_access_workaround_users,
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
      MAT.id=organisationvacancy.organisation_id) AS trust_level_vacancies_published,
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
      MAT.id=schoolgroupmembership.school_group_id) AS multischool_vacancies_published,
    COUNTIF(signed_up IS TRUE) AS schools_signed_up,
    COUNTIF(vacancies_published_in_the_last_year>0) AS schools_that_published_vacancies_in_the_last_year,
    COUNTIF(vacancies_published_in_the_last_quarter>0) AS schools_that_published_vacancies_in_the_last_quarter,
    COUNTIF(vacancies_published>0) AS schools_that_published_vacancies,
    COUNTIF(vacancies_currently_live>0) AS schools_with_live_vacancies
  FROM
    `teacher-vacancy-service.production_dataset.feb20_organisation` AS MAT
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
  ON
    MAT.id=schoolgroupmembership.school_group_id
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
    date_closed,
    companies_house_number,
    status )
ORDER BY
  trust_size DESC
