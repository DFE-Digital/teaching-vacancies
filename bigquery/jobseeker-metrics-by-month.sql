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
  actuals AS ( #put a table of actual metric values by month into a subquery so that we can give them names that make them easy to refer to in calculations in the main query
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
  goals AS (
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.monthly_goals_from_google_sheets`
  WHERE
    Month IS NOT NULL)
SELECT
  *,
  SAFE_DIVIDE(unique_users,
    unique_users_last_year) - 1 AS proportional_change_in_unique_users_from_last_year,
  SAFE_DIVIDE(unique_users,
    unique_users_last_year_COVID_adjusted) - 1 AS proportional_change_in_unique_users_from_last_year_COVID_adjusted
FROM (
  SELECT
    dates.month AS month,
    actuals.unique_users AS unique_users,
    (
    SELECT
      unique_users
    FROM
      actuals AS actuals_subquery
    WHERE
      actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)) AS unique_users_last_year,
    COALESCE((
      SELECT
        goals_subquery.COVID_adjusted_jobseekers_using_the_site
      FROM
        goals AS goals_subquery
      WHERE
        goals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)),
      (
      SELECT
        unique_users
      FROM
        actuals AS actuals_subquery
      WHERE
        actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR))) AS unique_users_last_year_COVID_adjusted,
    actuals.unique_jobseeker_searches AS unique_jobseeker_searches,
    actuals.jobseekers_taking_next_steps AS jobseekers_taking_next_steps,
    IF(dates.month <= CURRENT_DATE(),SUM(actuals.jobseekers_taking_next_steps) OVER (ORDER BY dates.month),NULL) AS jobseekers_taking_next_steps_so_far,
    #do a cumulative sum of the jobseekers_taking_next_steps metric
   IF(dates.month <= CURRENT_DATE(),(
    SELECT
      COUNT(*)
    FROM
      `teacher-vacancy-service.production_dataset.feb20_subscription` AS job_alerts
    WHERE
      DATE_TRUNC(CAST(created_at AS DATE), MONTH) = dates.month ),NULL) AS job_alerts_created,
    goals.Target___jobseekers_using_the_site AS Target_no_jobseekers_using_the_site,
    goals.Target___jobseekers_taking_next_steps AS Target_no_jobseekers_taking_next_steps,
    goals.Target_total___jobseekers_taking_next_steps AS Target_total_no_jobseekers_taking_next_steps
  FROM
    dates
  LEFT JOIN
    actuals
  USING(month)
  LEFT JOIN
    goals
  ON
    goals.Month = dates.month )
ORDER BY
  month ASC
