  # Filters the feb20_vacancies table into the vacancies_published view by excluding vacancies from out of scope statuses or roles
SELECT
  vacancy.id,
  job_title,
  slug,
  starts_on,
  ends_on,
  contact_email,
  status,
  expires_on,
  publish_on,
  vacancy.created_at,
  vacancy.updated_at,
  reference,
  application_link,
  weekly_pageviews,
  total_pageviews,
  weekly_pageviews_updated_at,
  total_pageviews_updated_at,
  total_get_more_info_clicks,
  total_get_more_info_clicks_updated_at,
  working_patterns,
  listed_elsewhere,
  hired_status,
  stats_updated_at,
  publisher_id,
  expires_at,
  salary,
  completed_step,
  about_school,
  state,
  subjects,
  school_visits,
  how_to_apply,
  initially_indexed,
  job_location,
  readable_job_location,
  suitable_for_nqt,
  job_roles,
  contact_number,
  publisher_organisation_id,
  #categorises each vacancy as leadership,teaching_assistant,teacher or NULL
  `teacher-vacancy-service.production_dataset.categorise_vacancy_job_title`(job_title) AS category,
  STRING_AGG(DISTINCT employer_organisation.phase, " and ") AS education_phase,
  STRING_AGG(DISTINCT employer_organisation.detailed_school_type, " and ") AS detailed_school_type,
  STRING_AGG(DISTINCT employer_organisation.school_type, " and ") AS school_type,
  STRING_AGG(DISTINCT employer_organisation.data_religiouscharacter_name, " and ") AS religious_character,
  LOGICAL_OR(employer_organisation.data_religiouscharacter_name IS NOT NULL
    AND employer_organisation.data_religiouscharacter_name NOT IN ("None",
      "Does not apply")) AS faith_school,
  STRING_AGG(DISTINCT employer_organisation.data_religiousethos_name, " and ") AS religious_ethos,
  STRING_AGG(DISTINCT employer_organisation.data_federationflag_name, " and ") AS federation_flag,
  COALESCE(publisher_organisation.group_type,
    STRING_AGG((
      SELECT
        DISTINCT schoolgroup.group_type
      FROM
        `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.feb20_organisation` AS schoolgroup
      ON
        schoolgroupmembership.school_group_id=schoolgroup.id
      WHERE
        schoolgroupmembership.school_id=employer_organisation.id), " and ")) AS schoolgroup_type,
  publisher_organisation.group_type AS publisher_schoolgroup_type,
IF
  (publisher_organisation.group_type = "Multi-academy trust",
    MAX((
      SELECT
        COUNT(DISTINCT schoolgroupmembership.school_id)
      FROM
        `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
      WHERE
        schoolgroupmembership.school_group_id=publisher_organisation.id)),
    MAX((
      SELECT
        COUNT(DISTINCT schoolgroupmembership.school_id)
      FROM
        `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership_parent
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
      USING
        (school_group_id)
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.feb20_organisation` AS schoolgroup
      ON
        schoolgroupmembership_parent.school_group_id=schoolgroup.id
      WHERE
        schoolgroupmembership_parent.school_id=employer_organisation.id
        AND schoolgroup.group_type = "Multi-academy trust"))) AS trust_size,
  #the number of organisations linked to this vacancy - if > 1 then this is a multi-school vacancy
  COUNT(DISTINCT organisation_id) AS number_of_organisations,
  #whether the vacancy was published at schoolgroup level e.g. a MAT (not the same as being published *by* a schoolgroup)
IF
  (job_location != "at_one_school",
    TRUE,
    FALSE) AS schoolgroup_level,
  (
  SELECT
    COUNT(document.id)
  FROM
    `teacher-vacancy-service.production_dataset.feb20_document` AS document
  WHERE
    document.vacancy_id=vacancy.id) AS number_of_documents
FROM
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_organisation` AS publisher_organisation
ON
  vacancy.publisher_organisation_id = publisher_organisation.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
ON
  vacancy.id=organisationvacancy.vacancy_id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_organisation` AS employer_organisation
ON
  organisationvacancy.organisation_id = employer_organisation.id
WHERE
  vacancy.status NOT IN ("trashed",
    "draft",
    "deleted")
GROUP BY
  vacancy.id,
  job_title,
  slug,
  starts_on,
  ends_on,
  contact_email,
  status,
  expires_on,
  publish_on,
  vacancy.created_at,
  vacancy.updated_at,
  reference,
  application_link,
  weekly_pageviews,
  total_pageviews,
  weekly_pageviews_updated_at,
  total_pageviews_updated_at,
  total_get_more_info_clicks,
  total_get_more_info_clicks_updated_at,
  working_patterns,
  listed_elsewhere,
  hired_status,
  stats_updated_at,
  publisher_id,
  expires_at,
  salary,
  completed_step,
  about_school,
  state,
  subjects,
  school_visits,
  how_to_apply,
  initially_indexed,
  job_location,
  readable_job_location,
  suitable_for_nqt,
  job_roles,
  contact_number,
  publisher_organisation_id,
  publisher_organisation.group_type
ORDER BY
  publish_on DESC
