  # Filters the feb20_vacancies table into the vacancies_in_scope view by excluding vacancies from out of scope statuses or roles
SELECT
  *
FROM (
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
          NULL))) AS category
  FROM
    `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
  WHERE
    vacancy.status NOT IN ("trashed",
      "draft",
      "deleted"))
WHERE
  category IN ("teacher",
    "leadership") #i.e. not null or teaching_assistant
