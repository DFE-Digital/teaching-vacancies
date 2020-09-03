  # Filters the vacancies_published view into the vacancies_in_scope view by excluding vacancies from out of scope roles
SELECT
  *
FROM
  `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
WHERE
  category IN ("teacher",
    "leadership") #i.e. not null or teaching_assistant
