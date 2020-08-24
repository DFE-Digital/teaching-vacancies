WITH
  dates AS ( #the range of dates we're calculating for - later, we could use this to limit the start date so we don't overwrite previously calculated data
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-04-25', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date ),
  vacancies AS (
  SELECT
    vacancy.id,
    MIN(vacancy.publish_on) AS publish_on,
    MIN(vacancy.expires_on) AS expires_on,
    vacancy.school_id,
    vacancy.job_roles AS job_roles,
    COUNT(document.id) AS number_of_documents
  FROM
    `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_document` AS document
  ON
    document.vacancy_id=vacancy.id
  WHERE
    (status NOT IN ("trashed",
        "deleted",
        "draft"))
  GROUP BY
    vacancy.id,
    school_id,
    job_roles ),
  vacancies_in_scope AS (
  SELECT
    vacancy.id,
    MIN(vacancy.publish_on) AS publish_on,
    MIN(vacancy.expires_on) AS expires_on,
    vacancy.school_id,
    vacancy.job_roles AS job_roles,
    vacancy.category AS category,
    COUNT(document.id) AS number_of_documents
  FROM
    `teacher-vacancy-service.production_dataset.vacancies_in_scope` AS vacancy
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_document` AS document
  ON
    document.vacancy_id=vacancy.id
  WHERE
    (status NOT IN ("trashed",
        "deleted",
        "draft"))
  GROUP BY
    vacancy.id,
    school_id,
    job_roles,
    category),
  scraped_vacancies_in_scope AS (
  SELECT
    scraped_vacancy.scraped_url AS url,
    MIN(scraped_vacancy.publish_on) AS publish_on,
    MIN(scraped_vacancy.expires_on) AS expires_on,
    scraped_vacancy.school_id,
    scraped_vacancy.vacancy_category AS category,
    scraped_vacancy.source AS source
  FROM
    `teacher-vacancy-service.production_dataset.scraped_vacancies_in_scope` AS scraped_vacancy
  GROUP BY
    url,
    school_id,
    category,
    source ),
  all_vacancy_metrics AS (
  SELECT
    dates.date AS date,
    COUNTIF(publish_on=date) AS vacancies_published,
    COUNTIF(expires_on=date) AS vacancies_expired,
    SUM(COUNTIF(publish_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(COUNTIF(expires_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_live_vacancies
  FROM
    dates
  CROSS JOIN
    vacancies
  GROUP BY
    date ),
  all_vacancy_in_scope_metrics AS (
  SELECT
    dates.date AS date,
    COUNTIF(publish_on=date) AS vacancies_in_scope_published,
    COUNTIF(expires_on=date) AS vacancies_in_scope_expired,
    SUM(COUNTIF(publish_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(COUNTIF(expires_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_in_scope_live_vacancies
  FROM
    dates
  CROSS JOIN
    vacancies_in_scope
  GROUP BY
    date ),
  all_benchmarks AS (
  SELECT
    dates.date AS date,
    COUNTIF(publish_on=date) AS benchmark_total_vacancies_published,
    COUNTIF(expires_on=date) AS benchmark_total_vacancies_expired,
    SUM(COUNTIF(publish_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(COUNTIF(expires_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS benchmark_total_live_vacancies
  FROM
    dates
  CROSS JOIN
    scraped_vacancies_in_scope
  WHERE
    scraped_vacancies_in_scope.source="TES"
  GROUP BY
    date ),
  vacancy_metrics AS ( (
    SELECT
      dates.date AS date,
      "all" AS tag,
      COUNTIF(publish_on=date) AS vacancies_published,
      COUNTIF(expires_on=date) AS vacancies_expired,
    FROM
      dates
    CROSS JOIN
      vacancies
    GROUP BY
      date )
  UNION ALL (
    SELECT
      dates.date AS date,
      "has_documents" AS tag,
      COUNTIF(publish_on=date
        AND number_of_documents>0) AS vacancies_published,
      COUNTIF(expires_on=date
        AND number_of_documents>0) AS vacancies_expired,
    FROM
      dates
    CROSS JOIN
      vacancies
    GROUP BY
      date )
  UNION ALL (
    SELECT
      dates.date AS date,
      "suitable_for_nqts" AS tag,
      COUNTIF(publish_on=date
        AND job_roles LIKE '%nqt%') AS vacancies_published,
      COUNTIF(expires_on=date
        AND job_roles LIKE '%nqt%') AS vacancies_expired,
    FROM
      dates
    CROSS JOIN
      vacancies
    GROUP BY
      date ) )
SELECT
  dates.date AS date,
  vacancy_metrics.tag AS tag,
  vacancy_metrics.vacancies_published AS vacancies_published_with_this_tag_on_this_date,
  all_vacancy_metrics.vacancies_published AS total_vacancies_published_on_this_date,
  all_vacancy_in_scope_metrics.vacancies_in_scope_published AS total_in_scope_vacancies_published_on_this_date,
  all_benchmarks.benchmark_total_vacancies_published AS benchmark_total_vacancies_published_on_this_date,
  SUM(vacancy_metrics.vacancies_published) OVER (PARTITION BY tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(vacancy_metrics.vacancies_expired) OVER (PARTITION BY tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS live_vacancies_with_this_tag,
  all_vacancy_metrics.total_live_vacancies AS total_live_vacancies,
  all_vacancy_in_scope_metrics.total_in_scope_live_vacancies AS total_in_scope_live_vacancies,
  all_benchmarks.benchmark_total_live_vacancies AS benchmark_total_live_vacancies,
  SAFE_DIVIDE(all_vacancy_in_scope_metrics.total_in_scope_live_vacancies,
    all_benchmarks.benchmark_total_live_vacancies) AS total_live_vacancies_as_proportion_of_benchmark,
  SAFE_DIVIDE(SUM(vacancy_metrics.vacancies_published) OVER (PARTITION BY tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(vacancy_metrics.vacancies_expired) OVER (PARTITION BY tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
    all_vacancy_metrics.total_live_vacancies) AS proportion_of_live_vacancies_with_this_tag
FROM
  dates
LEFT JOIN
  vacancy_metrics
USING
  (date)
LEFT JOIN
  all_vacancy_metrics
USING
  (date)
LEFT JOIN
  all_benchmarks
USING
  (date)
LEFT JOIN
  all_vacancy_in_scope_metrics
USING
  (date)
ORDER BY
  date ASC,
  tag ASC
