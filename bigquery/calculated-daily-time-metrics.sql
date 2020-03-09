WITH
  dates AS ( #the range of dates we're calculating for - later, we could use this to limit the start date so we don't overwrite previously calculated data
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-05-03', DATE_ADD(CURRENT_DATE(), INTERVAL 2 YEAR), INTERVAL 1 DAY)) AS date ),
  signup_metrics AS (
  SELECT
    date,
    SUM(schools_that_signed_up_on_each_date.schools_that_signed_up_on_this_date) OVER (ORDER BY date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS schools_signed_up
  FROM
    dates
  LEFT JOIN (
    SELECT
      date,
      (
      SELECT
        COUNT(DISTINCT urn),
      FROM (
        SELECT
          urn,
          signup_date,
          signed_up
        FROM
          `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics`) AS schools
      WHERE
        schools.signup_date IS NOT NULL
        AND schools.signup_date = dates.date
        AND schools.signed_up IS TRUE ) AS schools_that_signed_up_on_this_date
    FROM
      dates
    WHERE
      date <= CURRENT_DATE() ) AS schools_that_signed_up_on_each_date
  USING
    (date)
        WHERE
      date <= CURRENT_DATE()),
  published_vacancies_with_school_details AS ( #join some schools data we'll need later on to the vacancies table, and exclude unpublished vacancies
  SELECT
      vacancy.publish_on AS publish_on,
      vacancy.expires_on AS expires_on,
    school.urn AS school_urn
  FROM
    `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics` AS school
  ON
    vacancy.school_id=school.id
  WHERE
    vacancy.status != "trashed" #exclude deleted vacancies
    AND vacancy.status != "draft" #exclude vacancies which have not (yet) been published
    ),
  usage_metrics AS (
  SELECT
    date,
    ( #the total number of schools that published a vacancy before each date
    SELECT
      COUNT(DISTINCT
      IF
        (publish_on <= date,
          school_urn,
          NULL)),
    FROM
      published_vacancies_with_school_details ) AS schools_which_published_so_far,
    ( #the total number of schools that published a vacancy in the year before each date
    SELECT
      COUNT(DISTINCT
      IF
        (publish_on <= date
          AND publish_on > DATE_SUB(date, INTERVAL 1 YEAR),
          school_urn,
          NULL)),
    FROM
      published_vacancies_with_school_details ) AS schools_which_published_in_the_last_year,
    ( #the total number of schools that published a vacancy in the quarter before each date
    SELECT
      COUNT(DISTINCT
      IF
        (publish_on <= date
          AND publish_on > DATE_SUB(date, INTERVAL 3 MONTH),
          school_urn,
          NULL)),
    FROM
      published_vacancies_with_school_details ) AS schools_which_published_in_the_last_quarter,
    ( #the total number of schools that had a live vacancy on this date
    SELECT
      COUNT(DISTINCT
      IF
        (publish_on <= date
          AND expires_on > date,
          school_urn,
          NULL)),
    FROM
      published_vacancies_with_school_details ) AS schools_which_had_vacancies_live,
  FROM
    dates
  WHERE
    date <= CURRENT_DATE()),
  schools_in_scope AS (#the number of schools currently in scope in each region - currently this is assumed to be the current value of this for all time (we don't yet have the data from GIAS to be able to refine this further)
  SELECT
    *
  FROM (
    SELECT
      COUNT(*) AS schools_in_scope
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics` AS schools)
  CROSS JOIN
    dates )
SELECT
  dates.date,
  signup_metrics.schools_signed_up,
  goals.Expected_number_of_schools_with_a_user_account_by_this_date AS target_schools_signed_up,
  schools_in_scope.schools_in_scope,
  SAFE_DIVIDE(signup_metrics.schools_signed_up,
    schools_in_scope.schools_in_scope) AS proportion_of_schools_signed_up,
  goals.Expected___schools_with_a_user_account_by_this_date AS target_proportion_of_schools_signed_up,
  usage_metrics.schools_which_published_in_the_last_year AS schools_which_published_vacancies_in_the_last_year,
  usage_metrics.schools_which_published_in_the_last_quarter AS schools_which_published_vacancies_in_the_last_quarter,
  usage_metrics.schools_which_published_so_far AS schools_which_published_vacancies_so_far,
  usage_metrics.schools_which_had_vacancies_live AS schools_which_had_vacancies_live,
  SAFE_DIVIDE(usage_metrics.schools_which_published_in_the_last_year,
    schools_in_scope.schools_in_scope) AS proportion_of_schools_which_published_in_the_last_year,
  SAFE_DIVIDE(usage_metrics.schools_which_published_in_the_last_quarter,
    schools_in_scope.schools_in_scope) AS proportion_of_schools_which_published_in_the_last_quarter,
  SAFE_DIVIDE(usage_metrics.schools_which_published_so_far,
    schools_in_scope.schools_in_scope) AS proportion_of_schools_which_published_so_far,
  SAFE_DIVIDE(usage_metrics.schools_which_had_vacancies_live,
    schools_in_scope.schools_in_scope) AS proportion_of_schools_which_had_vacancies_live,
  SAFE_DIVIDE(usage_metrics.schools_which_published_in_the_last_year,
    signup_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_in_the_last_year,
  SAFE_DIVIDE(usage_metrics.schools_which_published_in_the_last_quarter,
    signup_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_in_the_last_quarter,
  SAFE_DIVIDE(usage_metrics.schools_which_published_so_far,
    signup_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_so_far,
  SAFE_DIVIDE(usage_metrics.schools_which_had_vacancies_live,
    signup_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_had_vacancies_live
FROM
  dates
LEFT JOIN
  signup_metrics
USING
  (date)
LEFT JOIN
  usage_metrics
USING
  (date)
LEFT JOIN
  schools_in_scope
USING
  (date)
LEFT JOIN `teacher-vacancy-service.production_dataset.nightly_goals_from_google_sheets` AS goals
  ON dates.date=goals.Date
ORDER BY date
