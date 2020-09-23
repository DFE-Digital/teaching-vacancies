WITH
  dates AS ( #the range of dates we're calculating for - later, we could use this to limit the start date so we don't overwrite previously calculated data
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-04-25', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date ),
  all_vacancy_metrics AS (
  SELECT
    dates.date AS date,
    COUNTIF(publish_on=date) AS vacancies_published,
    COUNTIF(expires_on=date) AS vacancies_expired,
    SUM(COUNTIF(publish_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(COUNTIF(expires_on=date)) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_live_vacancies
  FROM
    dates
  CROSS JOIN
    `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancies
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
    `teacher-vacancy-service.production_dataset.vacancies_in_scope` AS vacancies_in_scope
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
    `teacher-vacancy-service.production_dataset.scraped_vacancies_in_scope` AS scraped_vacancies_in_scope
  WHERE
    scraped_vacancies_in_scope.source="TES"
  GROUP BY
    date ),
  vacancy_metrics AS ( (
    SELECT
      dates.date AS date,
      tags.tag AS tag,
      CASE tags.tag
        WHEN "all" THEN COUNTIF(publish_on=date)
        WHEN "has_documents" THEN COUNTIF(publish_on=date
        AND number_of_documents>0)
        WHEN "suitable_for_nqts" THEN COUNTIF(publish_on=date AND job_roles LIKE '%nqt%')
        WHEN "mat_level" THEN COUNTIF(publish_on=date
        AND schoolgroup_level)
        WHEN "multi_school" THEN COUNTIF(publish_on=date AND number_of_organisations > 1)
    END
      AS vacancies_published,
      CASE tags.tag
        WHEN "all" THEN COUNTIF(expires_on=date)
        WHEN "has_documents" THEN COUNTIF(expires_on=date
        AND number_of_documents>0)
        WHEN "suitable_for_nqts" THEN COUNTIF(expires_on=date AND job_roles LIKE '%nqt%')
        WHEN "mat_level" THEN COUNTIF(expires_on=date
        AND schoolgroup_level)
        WHEN "multi_school" THEN COUNTIF(expires_on=date AND number_of_organisations > 1)
    END
      AS vacancies_expired,
    FROM
      dates
    CROSS JOIN (
      SELECT
        *
      FROM
        UNNEST(["all","has_documents","suitable_for_nqts","mat_level","multi_school"]) AS tag) AS tags
    CROSS JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancies
    GROUP BY
      date,
      tag ) )
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
    all_benchmarks.benchmark_total_live_vacancies) AS total_in_scope_live_vacancies_as_proportion_of_benchmark,
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
