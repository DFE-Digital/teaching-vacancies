WITH
  dates AS (
  SELECT
    DISTINCT month
  FROM (
    SELECT
      PARSE_DATE("%Y%m",
        CAST(Month_of_Year AS STRING)) AS month
    FROM
      `teacher-vacancy-service.production_dataset.GA_jobseeker_unique_users_by_month`
    UNION ALL
    SELECT
      PARSE_DATE("%Y%m",
        CAST(Month_of_Year AS STRING)) AS month
    FROM
      `teacher-vacancy-service.production_dataset.GA_jobseeker_searches_by_month`
    UNION ALL
    SELECT
      PARSE_DATE("%Y%m",
        CAST(Month_of_Year AS STRING)) AS month
    FROM
      `teacher-vacancy-service.production_dataset.GA_jobseekers_taking_next_steps_by_month`
    UNION ALL
    SELECT
      Month AS month
    FROM
      `teacher-vacancy-service.production_dataset.monthly_goals_from_google_sheets`)
  WHERE
    month IS NOT NULL
  ORDER BY
    month ASC ),
  GA_actuals AS ( #put a table of actual metric values by month into a subquery so that we can give them names that make them easy to refer to in calculations in the main query
  SELECT
    dates.month AS month,
    u.Users AS unique_users,
    s.Unique_Events AS unique_jobseeker_searches,
    n.ga_goal3Completions AS jobseekers_taking_next_steps
  FROM
    dates
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.GA_jobseeker_unique_users_by_month` AS u
  ON
    dates.month=PARSE_DATE("%Y%m",
      CAST(u.Month_of_Year AS STRING))
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.GA_jobseeker_searches_by_month` AS s
  ON
    dates.month=PARSE_DATE("%Y%m",
      CAST(s.Month_of_Year AS STRING))
  JOIN
    `teacher-vacancy-service.production_dataset.GA_jobseekers_taking_next_steps_by_month` AS n
  ON
    dates.month=PARSE_DATE("%Y%m",
      CAST(n.Month_of_Year AS STRING))),
  cloudfront_actuals AS (
  SELECT
    month,
    COUNTIF(type IS NOT NULL) AS number_of_users,
    COUNTIF(type="jobseeker") AS number_of_jobseekers,
    COUNTIF(type="hiring staff") AS number_of_hiring_staff,
    COUNTIF(device_category="mobile") AS number_of_mobile_users,
    COUNTIF(device_category="desktop") AS number_of_desktop_users,
    COUNTIF(type="jobseeker"
      AND viewed_a_vacancy) AS number_of_jobseekers_viewing_a_vacancy,
    COUNTIF(type="jobseeker"
      AND clicked_get_more_information) AS number_of_jobseekers_clicking_gmi,
    NULL AS jobseekers_taking_next_steps,
    COUNTIF(type="jobseeker"
      AND from_job_alert
      AND "vacancy" IN UNNEST(job_alert_destinations)) AS number_of_jobseekers_referred_from_job_alert_to_vacancy,
    COUNTIF(type="jobseeker"
      AND from_job_alert
      AND "edit" IN UNNEST(job_alert_destinations)) AS number_of_jobseekers_referred_from_job_alert_to_edit_alert,
    COUNTIF(type="jobseeker"
      AND from_job_alert
      AND "unsubscribe" IN UNNEST(job_alert_destinations)) AS number_of_jobseekers_referred_from_job_alert_to_unsubscribe_from_alert,
    SUM(
    IF
      (type="jobseeker",
        unique_searches,
        0)) AS unique_jobseeker_searches,
    SUM(
    IF
      (type="jobseeker",
        vacancies_viewed,
        0)) AS number_of_jobseeker_vacancy_views,
    SUM(
    IF
      (type="jobseeker",
        vacancies_with_gmi_clicks,
        0)) AS number_of_jobseeker_gmi_clicks,
  FROM
    dates
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.CALCULATED_monthly_users_from_cloudfront_logs` AS user
  USING
    (month)
  WHERE
    month < CURRENT_DATE()
  GROUP BY
    month
  HAVING
    number_of_users > 0 ),
  goals AS (
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.monthly_goals_from_google_sheets`
  WHERE
    month IS NOT NULL)
SELECT
  *,
  SAFE_DIVIDE(unique_jobseekers,
    unique_jobseekers_last_year) - 1 AS proportional_change_in_unique_jobseekers_from_last_year,
  SAFE_DIVIDE(unique_jobseekers,
    unique_jobseekers_last_year_COVID_adjusted) - 1 AS proportional_change_in_unique_jobseekers_from_last_year_COVID_adjusted
FROM (
  SELECT
    dates.month AS month,
    SAFE_DIVIDE(GA_actuals.unique_users,
      cloudfront_actuals.number_of_jobseekers) AS estimated_opt_in_rate,
  IF
    (dates.month < '2020-10-01',
      GA_actuals.unique_users,
      cloudfront_actuals.number_of_jobseekers) AS unique_jobseekers,
  IF
    (dates.month < '2021-10-01',
      (
      SELECT
        unique_users
      FROM
        GA_actuals AS actuals_subquery
      WHERE
        actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)),
      (
      SELECT
        number_of_jobseekers
      FROM
        cloudfront_actuals AS actuals_subquery
      WHERE
        actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR))) AS unique_jobseekers_last_year,
    COALESCE((
      SELECT
        goals_subquery.COVID_adjusted_jobseekers_using_the_site
      FROM
        goals AS goals_subquery
      WHERE
        goals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)),
    IF
      (dates.month < '2021-10-01',
        (
        SELECT
          unique_users
        FROM
          GA_actuals AS actuals_subquery
        WHERE
          actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)),
        (
        SELECT
          number_of_jobseekers
        FROM
          cloudfront_actuals AS actuals_subquery
        WHERE
          actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)))) AS unique_jobseekers_last_year_COVID_adjusted,
  IF
    (dates.month < '2020-10-01',
      GA_actuals.unique_jobseeker_searches,
      cloudfront_actuals.unique_jobseeker_searches) AS unique_jobseeker_searches,
  IF
    (dates.month < '2020-10-01',
      GA_actuals.jobseekers_taking_next_steps,
      NULL) AS unique_jobseekers_taking_next_steps,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_users) AS unique_users,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_hiring_staff) AS unique_hiring_staff,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_mobile_users) AS unique_mobile_users,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_desktop_users) AS unique_desktop_users,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseekers_viewing_a_vacancy) AS unique_jobseekers_viewing_a_vacancy,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseekers_clicking_gmi) AS unique_jobseekers_clicking_gmi,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseekers_referred_from_job_alert_to_vacancy) AS unique_jobseekers_referred_from_job_alert_to_vacancy,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseekers_referred_from_job_alert_to_edit_alert) AS unique_jobseekers_referred_from_job_alert_to_edit_alert,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseekers_referred_from_job_alert_to_unsubscribe_from_alert) AS unique_jobseekers_referred_from_job_alert_to_unsubscribe_from_alert,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseeker_vacancy_views) AS unique_vacancy_views,
  IF
    (dates.month < '2020-10-01',
      NULL,
      cloudfront_actuals.number_of_jobseeker_gmi_clicks) AS unique_gmi_clicks,
  IF
    (dates.month <= CURRENT_DATE(),
      (
      SELECT
        COUNT(*)
      FROM
        `teacher-vacancy-service.production_dataset.feb20_subscription` AS job_alerts
      WHERE
        DATE_TRUNC(CAST(created_at AS DATE), MONTH) = dates.month ),
      NULL) AS job_alerts_created,
    goals.Target___jobseekers_using_the_site AS Target_no_jobseekers_using_the_site,
    goals.Target___jobseekers_taking_next_steps AS Target_no_jobseekers_taking_next_steps,
    goals.Target_total___jobseekers_taking_next_steps AS Target_total_no_jobseekers_taking_next_steps
  FROM
    dates
  LEFT JOIN
    GA_actuals
  USING
    (month)
  LEFT JOIN
    cloudfront_actuals
  USING
    (month)
  LEFT JOIN
    goals
  ON
    goals.Month = dates.month )
ORDER BY
  month ASC
