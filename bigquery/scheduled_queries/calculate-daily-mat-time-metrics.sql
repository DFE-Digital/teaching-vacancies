  #scheduled query that appends new rows to CALCULATED_daily_MAT_time_metrics table
WITH
  dates AS ( #the range of dates we're calculating for
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2020-09-01', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date #all dates between 1/9/20 and yesterday
  WHERE
    #only calculate these metrics for dates we don't already have within this range
    date NOT IN (
    SELECT
      DISTINCT date
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_daily_MAT_time_metrics` ) ),
  trust_metrics AS (
  SELECT
    date,
    size_bracket,
    COUNT(uid) AS trusts_in_scope,
    COUNTIF(signed_up) AS trusts_signed_up,
    COUNTIF(using_mat_access_workaround) AS trusts_using_mat_access_workaround,
    COUNTIF(has_published_so_far) AS trusts_which_published_so_far,
    COUNTIF(has_published_in_the_last_year) AS trusts_which_published_in_the_last_year,
    COUNTIF(has_published_in_the_last_quarter) AS trusts_which_published_in_the_last_quarter,
    COUNTIF(had_live_vacancies) AS trusts_which_had_vacancies_live,
    COUNTIF(has_published_multischool_vacancies_so_far) AS trusts_which_published_multischool_vacancies_so_far,
    COUNTIF(has_published_multischool_vacancies_in_the_last_year) AS trusts_which_published_multischool_vacancies_in_the_last_year,
    COUNTIF(has_published_multischool_vacancies_in_the_last_quarter) AS trusts_which_published_multischool_vacancies_in_the_last_quarter,
    COUNTIF(had_live_multischool_vacancies) AS trusts_which_had_multischool_vacancies_live,
    COUNTIF(has_published_trust_level_vacancies_so_far) AS trusts_which_published_trust_level_vacancies_so_far,
    COUNTIF(has_published_trust_level_vacancies_in_the_last_year) AS trusts_which_published_trust_level_vacancies_in_the_last_year,
    COUNTIF(has_published_trust_level_vacancies_in_the_last_quarter) AS trusts_which_published_trust_level_vacancies_in_the_last_quarter,
    COUNTIF(had_live_trust_level_vacancies) AS trusts_which_had_trust_level_vacancies_live
  FROM (
    SELECT
      uid,
      date,
      size_bracket,
      using_mat_access_workaround,
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
      COUNTIF(schoolgroup_level) >= 1 AS has_published_trust_level_vacancies_so_far,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 1 YEAR)
        AND schoolgroup_level) >= 1 AS has_published_trust_level_vacancies_in_the_last_year,
      COUNTIF(vacancy.publish_on >= DATE_SUB(date,INTERVAL 3 MONTH)
        AND schoolgroup_level) >= 1 AS has_published_trust_level_vacancies_in_the_last_quarter,
      COUNTIF(vacancy.expires_on > date
        AND schoolgroup_level) >= 1 AS had_live_trust_level_vacancies
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_MATs_with_metrics` AS trust
    CROSS JOIN
      dates
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.dsi_users` AS user
    ON
      CAST(user.organisation_uid AS STRING) = trust.uid
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_userpreference` AS tv_user_logged_in
    ON
      tv_user_logged_in.school_group_id=trust.id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
    ON
      vacancy.publisher_user_id=tv_user_logged_in.user_id
    WHERE
      #only include trusts that were open on each date we're calculating for in the counts above
      (trust.status != "Closed"
        OR trust.date_closed > dates.date) #if the trust is not currently closed or if it closed after the date we're calculating for
      AND (trust.status != "Proposed to open" #and if the trust is not currently proposed to open
        OR trust.date_opened <= dates.date #or if the trust opened before the date we're calculating for
        )
      AND trust.date_created <= dates.date
      #only include vacancies which were published before the date we're calculating for in the counts above - or blank vacancies (so that we keep rows for the trusts, dates and users where there are no published vacancies)
      AND (vacancy.publish_on<date
        OR vacancy.publish_on IS NULL)
    GROUP BY
      uid,
      date,
      date_opened,
      date_created,
      date_closed,
      trust.status,
      trust.size_bracket,
      trust.using_mat_access_workaround)
  GROUP BY
    date,
    size_bracket )
SELECT
  *,
  SAFE_DIVIDE(trusts_signed_up,
    trusts_in_scope) AS proportion_of_trusts_signed_up,
  SAFE_DIVIDE(trusts_using_mat_access_workaround,
    trusts_in_scope) AS proportion_of_trusts_using_mat_access_workaround,
  SAFE_DIVIDE(trusts_which_published_vacancies_in_the_last_year,
    trusts_in_scope) AS proportion_of_trusts_which_published_in_the_last_year,
  SAFE_DIVIDE(trusts_which_published_vacancies_in_the_last_quarter,
    trusts_in_scope) AS proportion_of_trusts_which_published_in_the_last_quarter,
  SAFE_DIVIDE(trusts_which_published_vacancies_so_far,
    trusts_in_scope) AS proportion_of_trusts_which_published_so_far,
  SAFE_DIVIDE(trusts_which_had_vacancies_live,
    trusts_in_scope) AS proportion_of_trusts_which_had_vacancies_live,
  SAFE_DIVIDE(trusts_which_published_multischool_vacancies_in_the_last_year,
    trusts_in_scope) AS proportion_of_trusts_which_published_multischool_vacancies_in_the_last_year,
  SAFE_DIVIDE(trusts_which_published_multischool_vacancies_in_the_last_quarter,
    trusts_in_scope) AS proportion_of_trusts_which_published_multischool_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(trusts_which_published_multischool_vacancies_so_far,
    trusts_in_scope) AS proportion_of_trusts_which_published_multischool_vacancies_so_far,
  SAFE_DIVIDE(trusts_which_had_multischool_vacancies_live,
    trusts_in_scope) AS proportion_of_trusts_which_had_multischool_vacancies_live,
  SAFE_DIVIDE(trusts_which_published_trust_level_vacancies_in_the_last_year,
    trusts_in_scope) AS proportion_of_trusts_which_published_trust_level_vacancies_in_the_last_year,
  SAFE_DIVIDE(trusts_which_published_trust_level_vacancies_in_the_last_quarter,
    trusts_in_scope) AS proportion_of_trusts_which_published_trust_level_vacancies_in_the_last_quarter,
  SAFE_DIVIDE(trusts_which_published_trust_level_vacancies_so_far,
    trusts_in_scope) AS proportion_of_trusts_which_published_trust_level_vacancies_so_far,
  SAFE_DIVIDE(trusts_which_had_trust_level_vacancies_live,
    trusts_in_scope) AS proportion_of_trusts_which_had_trust_level_vacancies_live,
  SAFE_DIVIDE(trusts_which_published_vacancies_in_the_last_year,
    trusts_signed_up) AS proportion_of_signed_up_trusts_which_published_in_the_last_year,
  SAFE_DIVIDE(trusts_which_published_vacancies_in_the_last_quarter,
    trusts_signed_up) AS proportion_of_signed_up_trusts_which_published_in_the_last_quarter,
  SAFE_DIVIDE(trusts_which_published_vacancies_so_far,
    trusts_signed_up) AS proportion_of_signed_up_trusts_which_published_so_far,
  SAFE_DIVIDE(trusts_which_had_vacancies_live,
    trusts_signed_up) AS proportion_of_signed_up_trusts_which_had_vacancies_live,
FROM ( (
    SELECT
      dates.date,
      trust_metrics.size_bracket,
      trust_metrics.trusts_signed_up,
      trust_metrics.trusts_using_mat_access_workaround,
      trust_metrics.trusts_in_scope,
      trust_metrics.trusts_which_published_in_the_last_year AS trusts_which_published_vacancies_in_the_last_year,
      trust_metrics.trusts_which_published_in_the_last_quarter AS trusts_which_published_vacancies_in_the_last_quarter,
      trust_metrics.trusts_which_published_so_far AS trusts_which_published_vacancies_so_far,
      trust_metrics.trusts_which_had_vacancies_live AS trusts_which_had_vacancies_live,
      trust_metrics.trusts_which_published_multischool_vacancies_in_the_last_year AS trusts_which_published_multischool_vacancies_in_the_last_year,
      trust_metrics.trusts_which_published_multischool_vacancies_in_the_last_quarter AS trusts_which_published_multischool_vacancies_in_the_last_quarter,
      trust_metrics.trusts_which_published_multischool_vacancies_so_far AS trusts_which_published_multischool_vacancies_so_far,
      trust_metrics.trusts_which_had_multischool_vacancies_live AS trusts_which_had_multischool_vacancies_live,
      trust_metrics.trusts_which_published_trust_level_vacancies_in_the_last_year AS trusts_which_published_trust_level_vacancies_in_the_last_year,
      trust_metrics.trusts_which_published_trust_level_vacancies_in_the_last_quarter AS trusts_which_published_trust_level_vacancies_in_the_last_quarter,
      trust_metrics.trusts_which_published_trust_level_vacancies_so_far AS trusts_which_published_trust_level_vacancies_so_far,
      trust_metrics.trusts_which_had_trust_level_vacancies_live AS trusts_which_had_trust_level_vacancies_live
    FROM
      dates
    LEFT JOIN
      trust_metrics
    USING
      (date) )
  UNION ALL (
    SELECT
      dates.date,
      "all" AS size_bracket,
      SUM(trust_metrics.trusts_signed_up) AS trusts_signed_up,
      SUM(trust_metrics.trusts_using_mat_access_workaround) AS trusts_using_mat_access_workaround,
      SUM(trust_metrics.trusts_in_scope) AS trusts_in_scope,
      SUM(trust_metrics.trusts_which_published_in_the_last_year) AS trusts_which_published_vacancies_in_the_last_year,
      SUM(trust_metrics.trusts_which_published_in_the_last_quarter) AS trusts_which_published_vacancies_in_the_last_quarter,
      SUM(trust_metrics.trusts_which_published_so_far) AS trusts_which_published_vacancies_so_far,
      SUM(trust_metrics.trusts_which_had_vacancies_live) AS trusts_which_had_vacancies_live,
      SUM(trust_metrics.trusts_which_published_multischool_vacancies_in_the_last_year) AS trusts_which_published_multischool_vacancies_in_the_last_year,
      SUM(trust_metrics.trusts_which_published_multischool_vacancies_in_the_last_quarter) AS trusts_which_published_multischool_vacancies_in_the_last_quarter,
      SUM(trust_metrics.trusts_which_published_multischool_vacancies_so_far) AS trusts_which_published_multischool_vacancies_so_far,
      SUM(trust_metrics.trusts_which_had_multischool_vacancies_live) AS trusts_which_had_multischool_vacancies_live,
      SUM(trust_metrics.trusts_which_published_trust_level_vacancies_in_the_last_year) AS trusts_which_published_trust_level_vacancies_in_the_last_year,
      SUM(trust_metrics.trusts_which_published_trust_level_vacancies_in_the_last_quarter) AS trusts_which_published_trust_level_vacancies_in_the_last_quarter,
      SUM(trust_metrics.trusts_which_published_trust_level_vacancies_so_far) AS trusts_which_published_trust_level_vacancies_so_far,
      SUM(trust_metrics.trusts_which_had_trust_level_vacancies_live) AS trusts_which_had_trust_level_vacancies_live
    FROM
      dates
    LEFT JOIN
      trust_metrics
    USING
      (date)
    GROUP BY
      date ) )
ORDER BY
  date
