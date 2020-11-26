WITH
  dates AS ( #the range of dates we're calculating for - later, we could use this to limit the start date so we don't overwrite previously calculated data
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-04-25', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date ),
  vacancy_metrics AS (
  SELECT
    dates.date AS date,
    tags.tag AS tag,
    COUNTIF(publish_on=date) AS vacancies_published,
    COUNTIF(expires_on=date) AS vacancies_expired,
    COUNTIF(publish_on=date
      AND
      CASE tags.tag
        WHEN "all" THEN TRUE
        WHEN "in_scope" THEN category IN ("teacher",
        "leadership")
        WHEN "has_documents" THEN number_of_documents>0
        WHEN "suitable_for_nqts" THEN REGEXP_CONTAINS(job_roles,"(nqt)")
        WHEN "mat_level" THEN (schoolgroup_level AND publisher_schoolgroup_type="Multi-academy trust")
        WHEN "la_level" THEN (schoolgroup_level
        AND schoolgroup_type="local_authority")
        WHEN "multi_school" THEN number_of_organisations > 1
        WHEN "published_by_mat" THEN publisher_schoolgroup_type="Multi-academy trust"
        WHEN "published_by_la" THEN publisher_schoolgroup_type="local_authority"
        WHEN "la_maintained_school" THEN school_type="Local authority maintained schools"
        WHEN "faith_school" THEN faith_school
        WHEN "federation" THEN federation_flag="Supported by a federation"
        WHEN "free_school" THEN school_type="Free Schools"
        WHEN "mat" THEN schoolgroup_type="Multi-academy trust"
        WHEN "mat_21+" THEN (schoolgroup_type="Multi-academy trust" AND trust_size > 20)
        WHEN "mat_0-20" THEN (schoolgroup_type="Multi-academy trust"
        AND trust_size <= 20)
        WHEN "academy" THEN school_type="Academies"
        WHEN "flexible_working" THEN REGEXP_CONTAINS(working_patterns,"(part_time|job_share)")
        WHEN "primary" THEN education_phase IN ("primary", "middle_deemed_primary")
        WHEN "secondary" THEN education_phase IN ("secondary",
        "middle_deemed_secondary")
        WHEN "leadership" THEN category="leadership"
        WHEN "teacher" THEN category="teacher"
        WHEN "teaching_assistant" THEN category="teaching_assistant"
        WHEN "stem" THEN REGEXP_CONTAINS(subjects,"(Mathematics|Science|technology|ICT|Biology|Chemistry|Physics|Economics|Psychology|Sociology|Computing|Food|Engineering)")
        WHEN "sen" THEN (REGEXP_CONTAINS(job_roles,"(sen_specialist)") OR school_type="Special Schools")
    END
      ) AS vacancies_published_with_this_tag,
    COUNTIF(expires_on=date
      AND
      CASE tags.tag
        WHEN "all" THEN TRUE
        WHEN "in_scope" THEN category IN ("teacher",
        "leadership")
        WHEN "has_documents" THEN number_of_documents>0
        WHEN "suitable_for_nqts" THEN REGEXP_CONTAINS(job_roles,"(nqt)")
        WHEN "mat_level" THEN (schoolgroup_level AND publisher_schoolgroup_type="Multi-academy trust")
        WHEN "la_level" THEN (schoolgroup_level
        AND schoolgroup_type="local_authority")
        WHEN "multi_school" THEN number_of_organisations > 1
        WHEN "published_by_mat" THEN publisher_schoolgroup_type="Multi-academy trust"
        WHEN "published_by_la" THEN publisher_schoolgroup_type="local_authority"
        WHEN "la_maintained_school" THEN school_type="Local authority maintained schools"
        WHEN "faith_school" THEN faith_school
        WHEN "federation" THEN federation_flag="Supported by a federation"
        WHEN "free_school" THEN school_type="Free Schools"
        WHEN "mat" THEN schoolgroup_type="Multi-academy trust"
        WHEN "mat_21+" THEN (schoolgroup_type="Multi-academy trust" AND trust_size > 20)
        WHEN "mat_0-20" THEN (schoolgroup_type="Multi-academy trust"
        AND trust_size <= 20)
        WHEN "academy" THEN school_type="Academies"
        WHEN "flexible_working" THEN REGEXP_CONTAINS(working_patterns,"(part_time|job_share)")
        WHEN "primary" THEN education_phase IN ("primary", "middle_deemed_primary")
        WHEN "secondary" THEN education_phase IN ("secondary",
        "middle_deemed_secondary")
        WHEN "leadership" THEN category="leadership"
        WHEN "teacher" THEN category="teacher"
        WHEN "teaching_assistant" THEN category="teaching_assistant"
        WHEN "stem" THEN REGEXP_CONTAINS(subjects,"(Mathematics|Science|technology|ICT|Biology|Chemistry|Physics|Economics|Psychology|Sociology|Computing|Food|Engineering)")
        WHEN "sen" THEN (REGEXP_CONTAINS(job_roles,"(sen_specialist)") OR school_type="Special Schools")
    END
      ) AS vacancies_expired_with_this_tag,
  FROM
    dates
  CROSS JOIN (
    SELECT
      tag
    FROM
      UNNEST(["all","in_scope","has_documents","suitable_for_nqts","mat_level","la_level","multi_school","published_by_mat","published_by_la","la_maintained_school","faith_school","federation","free_school","mat","mat_21+","mat_0-20","academy","flexible_working","primary","secondary","leadership","teacher","teaching_assistant","stem","sen"]) AS tag) AS tags
  CROSS JOIN
    `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancies
  GROUP BY
    date,
    tag ),
  benchmark_vacancy_metrics AS (
  SELECT
    dates.date AS date,
    tags.tag AS tag,
    COUNTIF(publish_on=date) AS vacancies_published,
    COUNTIF(expires_on=date) AS vacancies_expired,
    COUNTIF(publish_on=date
      AND
      CASE tags.tag
        WHEN "all" THEN TRUE
        WHEN "in_scope" THEN vacancy_category IN ("teacher",
        "leadership")
        WHEN "has_documents" THEN NULL
        WHEN "suitable_for_nqts" THEN REGEXP_CONTAINS(description,"(?i)(nqt)")
        WHEN "mat_level" THEN school_id IS NULL AND school_group_id IS NOT NULL
        WHEN "la_level" THEN NULL
        WHEN "multi_school" THEN NULL
        WHEN "published_by_mat" THEN NULL
        WHEN "published_by_la" THEN NULL
        WHEN "la_maintained_school" THEN school_type="Local authority maintained schools"
        WHEN "faith_school" THEN school.religious_character IS NOT NULL AND school.religious_character NOT IN ("None", "Does not apply")
        WHEN "federation" THEN school.federation IS NOT NULL
        WHEN "free_school" THEN school_type="Free Schools"
        WHEN "mat" THEN school.trusts_school_flag="Supported by a multi-academy trust"
        WHEN "mat_21+" THEN NULL # MAT matching for crawled data not reliable enough, so this isn't likely to be statistically significant
        WHEN "mat_0-20" THEN NULL # MAT matching for crawled data not reliable enough, so this isn't likely to be statistically significant
        WHEN "academy" THEN school_type="Academies"
        WHEN "flexible_working" THEN employment_type="Part Time"
        WHEN "primary" THEN education_phase IN ("Primary", "Middle_deemed_primary")
        WHEN "secondary" THEN education_phase IN ("Secondary",
        "Middle_deemed_secondary")
        WHEN "leadership" THEN vacancy_category="leadership"
        WHEN "teacher" THEN vacancy_category="teacher"
        WHEN "teaching_assistant" THEN vacancy_category="teaching_assistant"
        WHEN "stem" THEN REGEXP_CONTAINS(description,"(?i)(Mathematics|Science|technology|ICT|Biology|Chemistry|Physics|Economics|Psychology|Sociology|Computing|Food|Engineering)")
        WHEN "sen" THEN (REGEXP_CONTAINS(title,"(?i)( sen |senco|special educational needs)") OR school_type="Special Schools")
    END
      ) AS vacancies_published_with_this_tag,
    COUNTIF(expires_on=date
      AND
      CASE tags.tag
        WHEN "all" THEN TRUE
        WHEN "in_scope" THEN vacancy_category IN ("teacher",
        "leadership")
        WHEN "has_documents" THEN NULL
        WHEN "suitable_for_nqts" THEN REGEXP_CONTAINS(description,"(?i)(nqt)")
        WHEN "mat_level" THEN school_id IS NULL AND school_group_id IS NOT NULL
        WHEN "la_level" THEN NULL
        WHEN "multi_school" THEN NULL
        WHEN "published_by_mat" THEN NULL
        WHEN "published_by_la" THEN NULL
        WHEN "la_maintained_school" THEN school_type="Local authority maintained schools"
        WHEN "faith_school" THEN school.religious_character IS NOT NULL AND school.religious_character NOT IN ("None", "Does not apply")
        WHEN "federation" THEN school.federation IS NOT NULL
        WHEN "free_school" THEN school_type="Free Schools"
        WHEN "mat" THEN school.trusts_school_flag="Supported by a multi-academy trust"
        WHEN "mat_21+" THEN NULL # MAT matching for crawled data not reliable enough, so this isn't likely to be statistically significant
        WHEN "mat_0-20" THEN NULL # MAT matching for crawled data not reliable enough, so this isn't likely to be statistically significant
        WHEN "academy" THEN school_type="Academies"
        WHEN "flexible_working" THEN employment_type="Part Time"
        WHEN "primary" THEN education_phase IN ("Primary", "Middle_deemed_primary")
        WHEN "secondary" THEN education_phase IN ("Secondary",
        "Middle_deemed_secondary")
        WHEN "leadership" THEN vacancy_category="leadership"
        WHEN "teacher" THEN vacancy_category="teacher"
        WHEN "teaching_assistant" THEN vacancy_category="teaching_assistant"
        WHEN "stem" THEN REGEXP_CONTAINS(description,"(?i)(Mathematics|Science|technology|ICT|Biology|Chemistry|Physics|Economics|Psychology|Sociology|Computing|Food|Engineering)")
        WHEN "sen" THEN (REGEXP_CONTAINS(title,"(?i)( sen |senco|special educational needs)") OR school_type="Special Schools")
    END
      ) AS vacancies_expired_with_this_tag,
  FROM
    dates
  CROSS JOIN (
    SELECT
      tag
    FROM
      UNNEST(["all","in_scope","has_documents","suitable_for_nqts","mat_level","la_level","multi_school","published_by_mat","published_by_la","la_maintained_school","faith_school","federation","free_school","mat","mat_21+","mat_0-20","academy","flexible_working","primary","secondary","leadership","teacher","teaching_assistant","stem","sen"]) AS tag) AS tags
  CROSS JOIN
    `teacher-vacancy-service.production_dataset.scraped_vacancies` AS scraped_vacancies
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.school` AS school
  ON
    scraped_vacancies.school_id=school.id
  WHERE
    scraped
    AND NOT expired_before_scrape
    AND (detailed_school_type_in_scope
      OR detailed_school_type IS NULL)
    AND (school_id IS NOT NULL
      OR school_group_id IS NOT NULL)
  GROUP BY
    date,
    tag )
SELECT
  date,
  tag,
  vacancies_published_with_this_tag_on_this_date,
IF
  (date>='2020-08-01',
    benchmark_vacancies_published_with_this_tag_on_this_date,
    NULL) AS benchmark_vacancies_published_with_this_tag_on_this_date,
  total_vacancies_published_on_this_date,
IF
  (date>='2020-08-01',
    benchmark_total_vacancies_published_on_this_date,
    NULL) AS benchmark_total_vacancies_published_on_this_date,
  total_live_vacancies,
  live_vacancies_with_this_tag,
IF
  (date>='2020-08-01',
    benchmark_total_live_vacancies,
    NULL) AS benchmark_total_live_vacancies,
IF
  (date>='2020-08-01',
    live_benchmark_vacancies_with_this_tag,
    NULL) AS live_benchmark_vacancies_with_this_tag,
  SAFE_DIVIDE(live_vacancies_with_this_tag,
    total_live_vacancies) AS proportion_of_live_vacancies_with_this_tag,
IF
  (date>='2020-08-01',
    SAFE_DIVIDE(live_benchmark_vacancies_with_this_tag,
      benchmark_total_live_vacancies),
    NULL) AS proportion_of_live_benchmark_vacancies_with_this_tag,
IF
  (date>='2020-08-01',
    SAFE_DIVIDE(live_vacancies_with_this_tag,
      live_benchmark_vacancies_with_this_tag),
    NULL) AS live_vacancies_with_this_tag_as_proportion_of_benchmark
FROM (
  SELECT
    dates.date AS date,
    vacancy_metrics.tag AS tag,
    vacancy_metrics.vacancies_published_with_this_tag AS vacancies_published_with_this_tag_on_this_date,
    benchmark_vacancy_metrics.vacancies_published_with_this_tag AS benchmark_vacancies_published_with_this_tag_on_this_date,
    vacancy_metrics.vacancies_published AS total_vacancies_published_on_this_date,
    benchmark_vacancy_metrics.vacancies_published AS benchmark_total_vacancies_published_on_this_date,
    SUM(vacancy_metrics.vacancies_published) OVER (PARTITION BY vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(vacancy_metrics.vacancies_expired) OVER (PARTITION BY vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_live_vacancies,
    SUM(vacancy_metrics.vacancies_published_with_this_tag) OVER (PARTITION BY vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(vacancy_metrics.vacancies_expired_with_this_tag) OVER (PARTITION BY vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS live_vacancies_with_this_tag,
    SUM(benchmark_vacancy_metrics.vacancies_published) OVER (PARTITION BY benchmark_vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(benchmark_vacancy_metrics.vacancies_expired) OVER (PARTITION BY benchmark_vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS benchmark_total_live_vacancies,
    SUM(benchmark_vacancy_metrics.vacancies_published_with_this_tag) OVER (PARTITION BY benchmark_vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - SUM(benchmark_vacancy_metrics.vacancies_expired_with_this_tag) OVER (PARTITION BY benchmark_vacancy_metrics.tag ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS live_benchmark_vacancies_with_this_tag,
  FROM
    dates
  LEFT JOIN
    vacancy_metrics
  USING
    (date)
  LEFT JOIN
    benchmark_vacancy_metrics
  USING
    (date,
      tag) )
ORDER BY
  date ASC,
  tag ASC
