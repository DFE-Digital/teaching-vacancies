SELECT
  id,
  relevant_to_user,
  comment,
  ARRAY_TO_STRING(ARRAY(
    SELECT
      CONCAT("https://teaching-vacancies.service.gov.uk/jobs/",vacancy.slug) AS vacancy_url
    FROM
      UNNEST(REGEXP_EXTRACT_ALL(vacancy_ids, "\"(.+?)\"")) AS vacancy_id
    JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    ON
      vacancy_id=vacancy.id),", ") AS vacancy_urls,
  ARRAY_TO_STRING(ARRAY(   #extract all search criteria from the JSON, except radius and location_category (because they are just location searches) and jobs_sort (because this isn't a search criterion)
    SELECT
      *
    FROM
      UNNEST(REGEXP_EXTRACT_ALL(search_criteria, r'\"([a-z_]+)\":')) AS criteria #we have to use REGEXP_EXTRACT_ALL here rather than JSON_EXTRACT... because the latter only supports value rather than key extraction
    WHERE
      criteria NOT IN ("radius",
        "jobs_sort",
        "location_category")
    ORDER BY
      criteria ASC )," and ") AS search_criteria,
IF
  (REGEXP_CONTAINS(JSON_EXTRACT_SCALAR(search_criteria,
        '$.location'), r"[0-9]+"),
    #anonymise postcodes
    "postcode",
    TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
          '$.location'))," ")) AS location,
  JSON_EXTRACT_SCALAR(search_criteria,
    '$.radius') AS radius,
  ARRAY_TO_STRING( (
    SELECT
      ARRAY(
      SELECT
        JSON_EXTRACT_SCALAR(working_patterns_string,
          '$') AS pattern
      FROM
        UNNEST(JSON_EXTRACT_ARRAY(search_criteria,
            '$.working_patterns')) AS working_patterns_string
      ORDER BY
        pattern ASC))," or ") AS working_patterns,
  JSON_EXTRACT_SCALAR(search_criteria,
    '$.newly_qualified_teacher') AS newly_qualified_teacher,
  ARRAY_TO_STRING( (
    SELECT
      ARRAY(
      SELECT
        JSON_EXTRACT_SCALAR(education_phases_string,
          '$') AS phase
      FROM
        UNNEST(JSON_EXTRACT_ARRAY(search_criteria,
            '$.phases')) AS education_phases_string
      ORDER BY
        phase ASC ))," or ") AS education_phases,
  TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
        '$.subject'))," ") AS subject,
  TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
        '$.job_title'))," ") AS job_title,
  TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
        '$.keyword'))," ") AS keyword,
FROM
  `teacher-vacancy-service.production_dataset.feb20_jobalertfeedback` AS feedback
WHERE
  recaptcha_score IS NULL
  OR recaptcha_score > 0.5
