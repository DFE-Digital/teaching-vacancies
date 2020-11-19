  #scheduled query that appends new rows to CALCULATED_daily_LA_time_metrics table
WITH
  dates AS ( #the range of dates we're calculating for
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2020-11-19', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date #all dates between 19/10/20 and yesterday
  WHERE
    #only calculate these metrics for dates we don't already have within this range
    date NOT IN (
    SELECT
      DISTINCT date
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_daily_LA_time_metrics` ) ),
  la_metrics AS (
  SELECT
    date,
    COUNT(code) AS las_in_scope,
    COUNTIF(signed_up) AS las_signed_up,
    COUNTIF(using_la_access_workaround) AS las_using_la_access_workaround,
    COUNTIF(has_published_so_far) AS las_which_published_so_far,
    COUNTIF(has_published_in_the_last_year) AS las_which_published_in_the_last_year,
    COUNTIF(has_published_in_the_last_quarter) AS las_which_published_in_the_last_quarter,
    COUNTIF(had_live_vacancies) AS las_which_had_vacancies_live,
    COUNTIF(has_published_multischool_vacancies_so_far) AS las_which_published_multischool_vacancies_so_far,
    COUNTIF(has_published_multischool_vacancies_in_the_last_year) AS las_which_published_multischool_vacancies_in_the_last_year,
    COUNTIF(has_published_multischool_vacancies_in_the_last_quarter) AS las_which_published_multischool_vacancies_in_the_last_quarter,
    COUNTIF(had_live_multischool_vacancies) AS las_which_had_multischool_vacancies_live,
    COUNTIF(has_published_la_level_vacancies_so_far) AS las_which_published_la_level_vacancies_so_far,
    COUNTIF(has_published_la_level_vacancies_in_the_last_year) AS las_which_published_la_level_vacancies_in_the_last_year,
    COUNTIF(has_published_la_level_vacancies_in_the_last_quarter) AS las_which_published_la_level_vacancies_in_the_last_quarter,
    COUNTIF(had_live_la_level_vacancies) AS las_which_had_la_level_vacancies_live
  FROM (
    SELECT
      la.code,
      date,
      using_la_access_workaround,
      COUNTIF(CAST(user.approval_datetime AS DATE) <= date) >= 1 AS signed_up,
      #Count the number of users who had access, see if it is 1 or more, and if so count the school as signed up
      COUNTIF(vacancy.id IS NOT NULL) >= 1 AS has_published_so_far,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 1 YEAR)) >= 1 AS has_published_in_the_last_year,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 3 MONTH)) >= 1 AS has_published_in_the_last_quarter,
      COUNTIF(vacancy.expires_on > date) >= 1 AS had_live_vacancies,
      COUNTIF(number_of_organisations > 1) >= 1 AS has_published_multischool_vacancies_so_far,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 1 YEAR)
        AND number_of_organisations > 1) >= 1 AS has_published_multischool_vacancies_in_the_last_year,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 3 MONTH)
        AND number_of_organisations > 1) >= 1 AS has_published_multischool_vacancies_in_the_last_quarter,
      COUNTIF(vacancy.expires_on > date
        AND number_of_organisations > 1) >= 1 AS had_live_multischool_vacancies,
      COUNTIF(schoolgroup_level) >= 1 AS has_published_la_level_vacancies_so_far,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 1 YEAR)
        AND schoolgroup_level) >= 1 AS has_published_la_level_vacancies_in_the_last_year,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 3 MONTH)
        AND schoolgroup_level) >= 1 AS has_published_la_level_vacancies_in_the_last_quarter,
      COUNTIF(vacancy.expires_on > date
        AND schoolgroup_level) >= 1 AS had_live_la_level_vacancies
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_local_authorities_with_metrics` AS la
    CROSS JOIN
      dates
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.dsi_users` AS user
    ON
      CAST(user.la_code AS STRING) = la.code
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    ON
      (vacancy.publisher_organisation_id=la.id
        AND publish_on<date)
    WHERE
      #only include trusts that were open on each date we're calculating for in the counts above
      (la.status != "Closed"
        OR la.date_closed > dates.date) #if the trust is not currently closed or if it closed after the date we're calculating for
      AND (la.status != "Proposed to open" #and if the trust is not currently proposed to open
        OR la.date_opened <= dates.date #or if the trust opened before the date we're calculating for
        )
      AND la.date_created <= dates.date
    GROUP BY
      la.code,
      date,
      date_opened,
      date_created,
      date_closed,
      la.status,
      la.using_la_access_workaround)
  GROUP BY
    date)
SELECT
  dates.date,
  las_signed_up,
  las_using_la_access_workaround,
  las_in_scope,
  las_which_published_in_the_last_year,
  las_which_published_in_the_last_quarter,
  las_which_published_so_far,
  las_which_had_vacancies_live,
  las_which_published_multischool_vacancies_in_the_last_year,
  las_which_published_multischool_vacancies_in_the_last_quarter,
  las_which_published_multischool_vacancies_so_far,
  las_which_had_multischool_vacancies_live,
  las_which_published_la_level_vacancies_in_the_last_year,
  las_which_published_la_level_vacancies_in_the_last_quarter,
  las_which_published_la_level_vacancies_so_far,
  las_which_had_la_level_vacancies_live,
  SAFE_DIVIDE(las_signed_up,
    las_in_scope) AS proportion_of_las_signed_up,
  SAFE_DIVIDE(las_using_la_access_workaround,
    las_in_scope) AS proportion_of_las_using_mat_access_workaround,
  SAFE_DIVIDE(las_which_published_in_the_last_year,
    las_in_scope) AS proportion_of_las_which_published_in_the_last_year,
  SAFE_DIVIDE(las_which_published_in_the_last_quarter,
    las_in_scope) AS proportion_of_las_which_published_in_the_last_quarter,
  SAFE_DIVIDE(las_which_published_so_far,
    las_in_scope) AS proportion_of_las_which_published_so_far,
  SAFE_DIVIDE(las_which_had_vacancies_live,
    las_in_scope) AS proportion_of_las_which_had_vacancies_live,
  SAFE_DIVIDE(las_which_published_multischool_vacancies_in_the_last_year,
    las_in_scope) AS proportion_of_las_which_published_multischool_vacancies_in_the_last_year,
  SAFE_DIVIDE(las_which_published_multischool_vacancies_in_the_last_quarter,
    las_in_scope) AS proportion_of_las_which_published_multischool_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(las_which_published_multischool_vacancies_so_far,
    las_in_scope) AS proportion_of_las_which_published_multischool_vacancies_so_far,
  SAFE_DIVIDE(las_which_had_multischool_vacancies_live,
    las_in_scope) AS proportion_of_las_which_had_multischool_vacancies_live,
  SAFE_DIVIDE(las_which_published_la_level_vacancies_in_the_last_year,
    las_in_scope) AS proportion_of_las_which_published_la_level_vacancies_in_the_last_year,
  SAFE_DIVIDE(las_which_published_la_level_vacancies_in_the_last_quarter,
    las_in_scope) AS proportion_of_las_which_published_la_level_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(las_which_published_la_level_vacancies_so_far,
    las_in_scope) AS proportion_of_las_which_published_la_level_vacancies_so_far,
  SAFE_DIVIDE(las_which_had_la_level_vacancies_live,
    las_in_scope) AS proportion_of_las_which_had_la_level_vacancies_live,
  SAFE_DIVIDE(las_which_published_in_the_last_year,
    las_signed_up) AS proportion_of_signed_up_las_which_published_in_the_last_year,
  SAFE_DIVIDE(las_which_published_in_the_last_quarter,
    las_signed_up) AS proportion_of_signed_up_las_which_published_in_the_last_quarter,
  SAFE_DIVIDE(las_which_published_so_far,
    las_signed_up) AS proportion_of_signed_up_las_which_published_so_far,
  SAFE_DIVIDE(las_which_had_vacancies_live,
    las_signed_up) AS proportion_of_signed_up_las_which_had_vacancies_live,
FROM
  dates
LEFT JOIN
  la_metrics
USING
  (date)
ORDER BY
  date
