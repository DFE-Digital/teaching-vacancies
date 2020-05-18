WITH
  actuals AS ( #put a table of actual metric values by month into a subquery so that we can give them names that make them easy to refer to in calculations in the main query
  SELECT
    PARSE_DATE("%Y%m",
      CAST(u.Month_of_Year AS STRING)) AS month,
    #turn an integer date from GA like '201803' into a date at the first day of that month '01-03-2018'
    u.Users AS unique_users,
    #the rest of this subquery joins three columns of three Google worksheets together
    s.Unique_Events AS unique_jobseeker_searches,
    n.ga_goal3Completions AS jobseekers_taking_next_steps
  FROM
    `teacher-vacancy-service.production_dataset.GA_jobseeker_unique_users_by_month` AS u
  JOIN
    `teacher-vacancy-service.production_dataset.GA_jobseeker_searches_by_month` AS s
  ON
    u.Month_of_Year=s.Month_of_Year
  JOIN
    `teacher-vacancy-service.production_dataset.GA_jobseekers_taking_next_steps_by_month` AS n
  ON
    u.Month_of_Year=n.Month_of_Year )
SELECT
  COALESCE(actuals.month,
    goals.month) AS month,
  #take the month from the actuals query if possible, but if not (i.e. for a future month with no actuals yet) get the month from the goals table
  actuals.unique_users AS unique_users,
  actuals.unique_jobseeker_searches AS unique_jobseeker_searches,
  actuals.jobseekers_taking_next_steps AS jobseekers_taking_next_steps,
  SUM(actuals.jobseekers_taking_next_steps) OVER (ORDER BY actuals.month) AS jobseekers_taking_next_steps_so_far,
  #do a cumulative sum of the jobseekers_taking_next_steps metric
  (
  SELECT
    COUNT(*)
  FROM
    `teacher-vacancy-service.production_dataset.feb20_subscription` AS job_alerts
  WHERE
    DATE_TRUNC(CAST(created_at AS DATE),
      MONTH) = actuals.month ) AS job_alerts_created,
  goals.Target_no_jobseekers_using_the_site AS Target_no_jobseekers_using_the_site,
  goals.Target_no_jobseekers_taking_next_steps AS Target_no_jobseekers_taking_next_steps,
  goals.Target_total_no_jobseekers_taking_next_steps AS Target_total_no_jobseekers_taking_next_steps
FROM
  actuals
FULL JOIN ( #Miss out all blank rows from the Google Sheet, and then join on the goals columns to the table
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.monthly_goals_from_google_sheets`
  WHERE
    Month IS NOT NULL) AS goals
ON
  goals.Month = actuals.month
ORDER BY
  month ASC
