  # Filters the feb20_vacancies table into the vacancies_published view by excluding vacancies from out of scope statuses or roles
SELECT
  vacancy.*,
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
        NULL))) AS category #categorises each vacancy as leadership,teaching_assistant,teacher or NULL
FROM
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
WHERE
  vacancy.status NOT IN ("trashed",
    "draft",
    "deleted")
