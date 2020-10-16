  # Filters the feb20_vacancies table into the vacancies_published view by excluding vacancies from out of scope statuses or roles
SELECT
  vacancy.*,
  #categorises each vacancy as leadership,teaching_assistant,teacher or NULL
IF
  (LOWER(job_title) LIKE '%head%'
    OR LOWER(job_title) LIKE '%ordinat%'
    OR LOWER(job_title) LIKE '%principal%',
    "leadership",
  IF
    ((job_title LIKE '%TA%'
        OR job_title LIKE '%TAs%'
        OR LOWER(job_title) LIKE '% assistant%' #picks up teaching assistant, learning support assistant etc.
        OR LOWER(job_title) LIKE '%intervention %')
      AND LOWER(job_title) NOT LIKE '%admin%'
      AND LOWER(job_title) NOT LIKE '%account%'
      AND LOWER(job_title) NOT LIKE '%marketing%'
      AND LOWER(job_title) NOT LIKE '%admission%'
      AND LOWER(job_title) NOT LIKE '%care%',
      "teaching_assistant",
    IF
      (LOWER(job_title) LIKE '%teacher%'
        OR LOWER(job_title) LIKE '%lecturer%',
        "teacher",
        NULL))) AS category,
  #the number of organisations linked to this vacancy - if > 1 then this is a multi-school vacancy
  (
  SELECT
    COUNT(organisation_id)
  FROM
    `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
  WHERE
    organisationvacancy.vacancy_id=vacancy.id) AS number_of_organisations,
  #whether the vacancy was published by a schoolgroup e.g. a MAT
  (
  SELECT
    COUNT(organisationvacancy.id)
  FROM
    `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_organisation` AS organisation
  ON
    organisation.id=organisationvacancy.organisation_id
  WHERE
    organisation.type="SchoolGroup"
    AND organisationvacancy.vacancy_id=vacancy.id) > 0 AS schoolgroup_level,
  (
  SELECT
    COUNT(document.id)
  FROM
    `teacher-vacancy-service.production_dataset.feb20_document` AS document
  WHERE
    document.vacancy_id=vacancy.id) AS number_of_documents
FROM
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
WHERE
  vacancy.status NOT IN ("trashed",
    "draft",
    "deleted")
