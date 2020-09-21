WITH
  current_vacancy_counts AS (
  SELECT
    #pull counts for today for sites we benchmark against from a Google Sheet
    CURRENT_DATE() AS date,
    Site AS site,
    Current_number_of_comparable_vacancies AS number_of_vacancies
  FROM
    `teacher-vacancy-service.production_dataset.current_vacancy_counts_from_comparable_sites_from_google_sheets`
  WHERE
    #don't take obviously erroneous values from the Google Sheet
    Site IS NOT NULL
    AND Current_number_of_comparable_vacancies > 0 )
SELECT
  *
FROM (
  SELECT
    *
  FROM
    current_vacancy_counts
  UNION ALL (
    SELECT
      *
    FROM (
        #pull count for today for Teaching Vacancies from our own vacancy table
      SELECT
        CURRENT_DATE() AS date,
        "Teaching Vacancies" AS site,
        COUNT(*) AS number_of_vacancies
      FROM
        `teacher-vacancy-service.production_dataset.feb20_vacancy`
      WHERE
        status NOT IN ("deleted",
          "trashed",
          "draft")
        AND publish_on <= CURRENT_DATE()
        AND expiry_time > CURRENT_DATETIME())
    WHERE
      "Teaching Vacancies" NOT IN ( #only take the Teaching Vacancies vacancy count from our database if we haven't been able to web scrape it (to avoid relying on the write job to this large table)
      SELECT
        site
      FROM
        current_vacancy_counts)))
WHERE
  site NOT IN (
  SELECT
    site
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_benchmark_live_vacancy_counts`
  WHERE
    date = CURRENT_DATE()) #don't append duplicate values for sites that already have a recorded value for today
