WITH
  dates AS ( #the range of dates we're calculating for - later, we could use this to limit the start date so we don't overwrite previously calculated data
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-05-03', DATE_ADD(CURRENT_DATE(), INTERVAL 2 YEAR), INTERVAL 1 DAY)) AS date ),
  RSC_regions AS (
  SELECT
    DISTINCT RSC_region
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics`
  WHERE
    RSC_region IS NOT NULL),
  RSC_region_dates AS ( #every possible combination of date and RSC region
  SELECT
    date,
    RSC_region
  FROM
    dates
  CROSS JOIN
    RSC_regions
  ORDER BY
    date,
    RSC_region ASC ),
  signup_metrics AS (
  SELECT
    date,
    RSC_region,
    ( #the total number of schools that had signed up by each date in each region
    SELECT
      COUNT(DISTINCT urn)
    FROM (
      SELECT
        urn,
        signup_date,
        RSC_region AS school_RSC_region,
        signed_up
      FROM
        `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics`) AS schools
    WHERE
      schools.signup_date IS NOT NULL
      AND schools.signup_date <= date
      AND schools.school_RSC_region=RSC_region
      AND schools.signed_up IS TRUE ) AS schools_signed_up
  FROM
    RSC_region_dates
  WHERE
    date <= CURRENT_DATE()),
  published_vacancies_with_school_details AS ( #join some schools data we'll need later on to the vacancies table, and exclude unpublished vacancies
  SELECT
    PARSE_DATE("%e %B %E4Y",
      vacancy.publish_on) AS publish_on,
    PARSE_DATE("%e %B %E4Y",
      vacancy.expires_on) AS expires_on,
    school.urn AS school_urn,
    school.RSC_region AS school_RSC_region
  FROM
    `teacher-vacancy-service.production_dataset.vacancy` AS vacancy
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
    RSC_region,
    ( #the total number of schools that published a vacancy before each date
    SELECT
      COUNT(DISTINCT school_urn),
    FROM
      published_vacancies_with_school_details
    WHERE
      publish_on <= date
      AND RSC_region=school_RSC_region ) AS schools_which_published_so_far,
    ( #the total number of schools that published a vacancy in the year before each date
    SELECT
      COUNT(DISTINCT school_urn),
    FROM
      published_vacancies_with_school_details
    WHERE
      publish_on <= date
      AND publish_on > DATE_SUB(date, INTERVAL 1 YEAR)
      AND RSC_region=school_RSC_region ) AS schools_which_published_in_the_last_year,
    ( #the total number of schools that published a vacancy in the quarter before each date
    SELECT
      COUNT(DISTINCT school_urn),
    FROM
      published_vacancies_with_school_details
    WHERE
      publish_on <= date
      AND publish_on > DATE_SUB(date, INTERVAL 3 MONTH)
      AND RSC_region=school_RSC_region ) AS schools_which_published_in_the_last_quarter,
    ( #the total number of schools that had a live vacancy on this date
    SELECT
      COUNT(DISTINCT school_urn),
    FROM
      published_vacancies_with_school_details
    WHERE
      publish_on <= date
      AND expires_on > date
      AND RSC_region=school_RSC_region ) AS schools_which_had_vacancies_live,
  FROM
    RSC_region_dates
  WHERE
    date <= CURRENT_DATE()),
  schools_in_scope AS ( #the number of schools currently in scope in each region - currently this is assumed to be the current value of this for all time (we don't yet have the data from GIAS to be able to refine this further)
  SELECT
    COUNT(*) AS schools_in_scope,
    RSC_region
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_schools_joined_with_metrics` AS schools
  GROUP BY
    RSC_region )
SELECT
  RSC_region_dates.date,
  RSC_region_dates.RSC_region,
  signup_metrics.schools_signed_up,
  schools_in_scope.schools_in_scope,
  SAFE_DIVIDE(signup_metrics.schools_signed_up,
    schools_in_scope.schools_in_scope) AS proportion_of_schools_signed_up,
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
  RSC_region_dates
LEFT JOIN
  signup_metrics
ON
  signup_metrics.date=RSC_region_dates.date
  AND signup_metrics.RSC_region=RSC_region_dates.RSC_region
LEFT JOIN
  usage_metrics
ON
  usage_metrics.date=RSC_region_dates.date
  AND usage_metrics.RSC_region=RSC_region_dates.RSC_region
LEFT JOIN
  schools_in_scope
ON
  schools_in_scope.RSC_region=signup_metrics.RSC_region
ORDER BY
  date,
  RSC_region ASC
