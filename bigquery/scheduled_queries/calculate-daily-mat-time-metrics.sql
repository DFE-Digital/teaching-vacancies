  #scheduled query that appends new rows to CALCULATED_daily_MAT_time_metrics table
WITH
  dates AS ( #the range of dates we're calculating for
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2020-09-01', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date
  WHERE
    #only calculate these metrics for dates we don't already have within this range
    date NOT IN (
    SELECT
      DISTINCT date
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_daily_MAT_time_metrics`) ),
  trust_metrics AS (
  SELECT
    date,
    size_bracket,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(in_scope)) AS trusts_in_scope,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(signed_up)) AS trusts_signed_up,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(using_mat_access_workaround)) AS trusts_using_mat_access_workaround,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_so_far)) AS trusts_which_published_so_far,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_in_the_last_year)) AS trusts_which_published_in_the_last_year,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_in_the_last_quarter)) AS trusts_which_published_in_the_last_quarter,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(had_live_vacancies)) AS trusts_which_had_vacancies_live,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_multischool_vacancies_so_far)) AS trusts_which_published_multischool_vacancies_so_far,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_multischool_vacancies_in_the_last_year)) AS trusts_which_published_multischool_vacancies_in_the_last_year,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_multischool_vacancies_in_the_last_quarter)) AS trusts_which_published_multischool_vacancies_in_the_last_quarter,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(had_live_multischool_vacancies)) AS trusts_which_had_multischool_vacancies_live,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_trust_level_vacancies_so_far)) AS trusts_which_published_trust_level_vacancies_so_far,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_trust_level_vacancies_in_the_last_year)) AS trusts_which_published_trust_level_vacancies_in_the_last_year,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_trust_level_vacancies_in_the_last_quarter)) AS trusts_which_published_trust_level_vacancies_in_the_last_quarter,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(had_live_trust_level_vacancies)) AS trusts_which_had_trust_level_vacancies_live
  FROM (
    SELECT
      trusts.uid AS uid,
      dates.date AS date,
      trusts.size_bracket AS size_bracket,
      trusts.using_mat_access_workaround AS using_mat_access_workaround,
    IF
      ((trusts.status != "Closed"
          OR trusts.date_closed > dates.date) #if the trust is not currently closed or if it closed after the date we're calculating for
        AND (trusts.status != "Proposed to open" #and if the trust is not currently proposed to open
          OR trusts.date_opened <= dates.date #or if the trust opened before the date we're calculating for
          )
        AND trusts.date_created <= dates.date,
        #and if the trust was first listed on GIAS before or on the date we're calculating for
        TRUE,
        FALSE) AS in_scope,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not signed up
      IF
        (COUNTIF(CAST(users.approval_datetime AS DATE) <= dates.date) >= 1,
          #Count the number of users who had access, see if it is 1 or more, and if so count the school as signed up
          TRUE,
          FALSE)) AS signed_up,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published
      IF
        (COUNTIF(vacancies.publish_on <= dates.date) > 1,
          TRUE,
          FALSE)) AS has_published_so_far,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published in the last year
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 1 YEAR)) > 1,
          TRUE,
          FALSE)) AS has_published_in_the_last_year,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published in the last quarter
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 3 MONTH)) > 1,
          TRUE,
          FALSE)) AS has_published_in_the_last_quarter,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having had live vacancies
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.expires_on > dates.date) > 1,
          TRUE,
          FALSE)) AS had_live_vacancies,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND number_of_organisations > 1) > 1,
          TRUE,
          FALSE)) AS has_published_multischool_vacancies_so_far,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published in the last year
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 1 YEAR)
            AND number_of_organisations > 1) > 1,
          TRUE,
          FALSE)) AS has_published_multischool_vacancies_in_the_last_year,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published in the last quarter
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 3 MONTH)
            AND number_of_organisations > 1) > 1,
          TRUE,
          FALSE)) AS has_published_multischool_vacancies_in_the_last_quarter,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having had live vacancies
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.expires_on > dates.date
            AND number_of_organisations > 1) > 1,
          TRUE,
          FALSE)) AS had_live_multischool_vacancies,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND schoolgroup_level) > 1,
          TRUE,
          FALSE)) AS has_published_trust_level_vacancies_so_far,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published in the last year
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 1 YEAR)
            AND schoolgroup_level) > 1,
          TRUE,
          FALSE)) AS has_published_trust_level_vacancies_in_the_last_year,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having published in the last quarter
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 3 MONTH)
            AND schoolgroup_level) > 1,
          TRUE,
          FALSE)) AS has_published_trust_level_vacancies_in_the_last_quarter,
    IF
      ((trusts.status = "Closed"
          AND trusts.date_closed <= dates.date)
        OR trusts.date_opened > dates.date,
        FALSE,
        #mark trusts which had closed or had not yet opened as not having had live vacancies
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.expires_on > dates.date
            AND schoolgroup_level) > 1,
          TRUE,
          FALSE)) AS had_live_trust_level_vacancies
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_MATs_with_metrics` AS trusts
    CROSS JOIN
      dates
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.dsi_users` AS users
    ON
      CAST(users.organisation_uid AS STRING) = trusts.uid
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_userpreference` AS tv_users_logged_in
    ON
      tv_users_logged_in.school_group_id=trusts.id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancies
    ON
      vacancies.publisher_user_id=tv_users_logged_in.user_id
    GROUP BY
      uid,
      date,
      date_opened,
      date_created,
      date_closed,
      trusts.status,
      trusts.size_bracket,
      trusts.using_mat_access_workaround)
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
