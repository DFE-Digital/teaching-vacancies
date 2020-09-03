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
  opt_in_rates AS (
  SELECT
    month,
    SUM(estimated_opt_in_rate_unnormalised*clicks)/SUM(clicks) AS estimated_opt_in_rate #see note on the unnormalised opt in rate - however this is normalised across mobile, desktop and tablet (devices) i.e. weighting the opt in rate for more commonly used devices more than less commonly used devices
  FROM (
    SELECT
      month,
      device,
      SUM(clicks) AS clicks,
      #the total number of clicks on Teaching Vacancies links recorded in Google Search Console
      SUM(organic_searches) AS organic_searches,
      #the total number of organic searches recorded as part of sessions in Google Analytics
      SUM(estimated_organic_searches) AS estimated_organic_searches,
      #an estimate of the 'actual' number of organic searches that took place within sessions, calculated from the number of clicks from Google Search Console
      SUM(organic_searches)/SUM(estimated_organic_searches) AS estimated_opt_in_rate_unnormalised #an estimate of the proportion of searches where the user was opted in to cookies - we will use this as an estimate of the number of users who opted in to cookies (a significant assumption, but OK for an estimate)
    FROM (
      SELECT
        date,
        device,
        clicks,
        organic_searches,
      IF
        (date < '2020-09-01',
          organic_searches,
          CAST((clicks / 1.578) AS INT64) ) AS estimated_organic_searches,
        #After 1st September 2020, use the number of clicks from Google Search Console to estimate the number of organic searches that would have been recorded in Google Analytics had we not switched on cookie opt-in/out. The scale factor 1.578 was calculated using data for the 18 months to this date using a linear regression model with fixed 0-intercept, resulting in an R2 of 0.971.
        DATE_TRUNC(date, MONTH) AS month
      FROM
        `teacher-vacancy-service.production_dataset.GSC_google_search_clicks_historic` AS GSC
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.GA_tracked_organic_searches_historic` AS GA
      USING
        (date,
          device))
    GROUP BY
      month,
      device )
  GROUP BY
    month
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
  SAFE_DIVIDE(tracked_unique_users,
    tracked_unique_users_last_year) - 1 AS proportional_change_in_tracked_unique_users_from_last_year,
  SAFE_DIVIDE(tracked_unique_users,
    tracked_unique_users_last_year_COVID_adjusted) - 1 AS proportional_change_in_tracked_unique_users_from_last_year_COVID_adjusted,
  SAFE_DIVIDE(estimated_unique_users,
    estimated_unique_users_last_year) - 1 AS proportional_change_in_estimated_unique_users_from_last_year,
  SAFE_DIVIDE(estimated_unique_users,
    estimated_unique_users_last_year_COVID_adjusted) - 1 AS proportional_change_in_estimated_unique_users_from_last_year_COVID_adjusted
FROM (
  SELECT
    dates.month AS month,
    estimated_opt_in_rate,
    actuals.unique_users AS tracked_unique_users,
    CAST(actuals.unique_users/
    IF
      (estimated_opt_in_rate IS NOT NULL,
        estimated_opt_in_rate,
        1) AS INT64) AS estimated_unique_users,
    (
    SELECT
      unique_users
    FROM
      actuals AS actuals_subquery
    WHERE
      actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)) AS tracked_unique_users_last_year,
    (
    SELECT
      CAST(actuals_subquery.unique_users/
      IF
        (opt_in_rates_subquery.estimated_opt_in_rate IS NOT NULL,
          opt_in_rates_subquery.estimated_opt_in_rate,
          1) AS INT64)
    FROM
      actuals AS actuals_subquery
    LEFT JOIN
      opt_in_rates AS opt_in_rates_subquery
    USING
      (month)
    WHERE
      actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)) AS estimated_unique_users_last_year,
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
        actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR))) AS tracked_unique_users_last_year_COVID_adjusted,
    COALESCE((
      SELECT
        goals_subquery.COVID_adjusted_jobseekers_using_the_site
      FROM
        goals AS goals_subquery
      WHERE
        goals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR)),
      (
      SELECT
        CAST(actuals_subquery.unique_users/
        IF
          (opt_in_rates_subquery.estimated_opt_in_rate IS NOT NULL,
            opt_in_rates_subquery.estimated_opt_in_rate,
            1) AS INT64)
      FROM
        actuals AS actuals_subquery
      LEFT JOIN
        opt_in_rates AS opt_in_rates_subquery
      USING
        (month)
      WHERE
        actuals_subquery.month=DATE_SUB(dates.month, INTERVAL 1 YEAR))) AS estimated_unique_users_last_year_COVID_adjusted,
    actuals.unique_jobseeker_searches AS tracked_unique_jobseeker_searches,
    CAST(actuals.unique_jobseeker_searches/
    IF
      (opt_in_rates.estimated_opt_in_rate IS NOT NULL,
        opt_in_rates.estimated_opt_in_rate,
        1) AS INT64) AS estimated_unique_jobseeker_searches,
    actuals.jobseekers_taking_next_steps AS tracked_jobseekers_taking_next_steps,
    CAST(actuals.jobseekers_taking_next_steps/
    IF
      (opt_in_rates.estimated_opt_in_rate IS NOT NULL,
        opt_in_rates.estimated_opt_in_rate,
        1) AS INT64) AS estimated_jobseekers_taking_next_steps,
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
    actuals
  USING
    (month)
  LEFT JOIN
    opt_in_rates
  USING
    (month)
  LEFT JOIN
    goals
  ON
    goals.Month = dates.month )
ORDER BY
  month ASC
