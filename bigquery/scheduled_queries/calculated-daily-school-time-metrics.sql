WITH
  dates AS ( #the range of dates we're calculating for - later, we could use this to limit the start date so we don't overwrite previously calculated data
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-05-03', DATE_ADD(CURRENT_DATE(), INTERVAL 2 YEAR), INTERVAL 1 DAY)) AS date ),
  schools AS (
  SELECT
    URN,
    id,
    date_closed,
    date_opened,
    CAST(date_created AS DATE) AS date_created,
    status,
    ARRAY_TO_STRING(ARRAY(
      SELECT
        DISTINCT trust.id
      FROM
        `teacher-vacancy-service.production_dataset.schoolgroup` AS trust
      LEFT JOIN
        `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership
      ON
        trust.id=schoolgroupmembership.school_group_id
      WHERE
        trust.type = "Multi-academy trust"
        AND schoolgroupmembership.school_id=school.id
        AND trust.status != "Closed"),", ") AS trust_id,
  FROM
    `teacher-vacancy-service.production_dataset.school` AS school
  WHERE
    ((date_closed IS NULL
        AND status != "Closed")
      OR (status = "Closed"
        AND date_closed > '2018-05-03'))
    AND detailed_school_type_in_scope),
  school_metrics AS (
  SELECT
    date,
    COUNTIF(urn IS NOT NULL) AS schools_in_scope,
    COUNTIF(signed_up) AS schools_signed_up,
    COUNTIF(has_published_so_far) AS schools_which_published_so_far,
    COUNTIF(has_published_in_the_last_year) AS schools_which_published_in_the_last_year,
    COUNTIF(has_published_in_the_last_quarter) AS schools_which_published_in_the_last_quarter,
    COUNTIF(had_live_vacancies) AS schools_which_had_vacancies_live
  FROM (
    SELECT
      schools.urn AS urn,
      dates.date AS date,
    IF
      #up until 20th November 2019, take signup data from the static table of historic signup data for each school
      ( historic_signups.School_been_added
        AND dates.date<='2019-11-20',
        historic_signups.Date_first_signed_up<dates.date,
        #after 20th November 2019, count the number of users who had access, see if it is 1 or more, and if so count the school as signed up
        (
        SELECT
          COUNT(users.user_id)
        FROM
          `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users` AS users
        WHERE
          users.school_urn = CAST(schools.urn AS INT64)
          AND users.from_date <= dates.date
          AND (users.to_date IS NULL
            OR users.to_date > dates.date)) + (
        SELECT
          COUNT(users.user_id)
        FROM
          `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users` AS users
        WHERE
          users.organisation_uid=trust.uid
          AND users.from_date <= dates.date
          AND (users.to_date IS NULL
            OR users.to_date > dates.date)) >= 1 ) AS signed_up,
      COUNTIF(vacancies.id IS NOT NULL) >= 1 AS has_published_so_far,
      COUNTIF(vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 1 YEAR)) >= 1 AS has_published_in_the_last_year,
      COUNTIF(vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 3 MONTH)) >= 1 AS has_published_in_the_last_quarter,
      COUNTIF(vacancies.expires_on > dates.date) >= 1 AS had_live_vacancies
    FROM
      schools
    CROSS JOIN
      dates
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.STATIC_schools_historic_pre201119` AS historic_signups
    ON
      CAST(historic_signups.URN AS STRING) = schools.urn
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.schoolgroup` AS trust
    ON
      trust.id = schools.trust_id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
    ON
      schools.id=organisationvacancy.organisation_id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancies
    ON
      vacancies.id=organisationvacancy.vacancy_id
      AND vacancies.publish_on <= dates.date
    WHERE
      #only include schools in the above counts when they were open on the day that we're calculating for
      (schools.status != "Closed" #if the school is not currently closed
        OR schools.date_closed > dates.date) #or if the school closed after the date we're calculating for
      AND (schools.status != "Proposed to open" #and if the school is not currently proposed to open
        OR schools.date_opened <= dates.date #or if the school opened before the date we're calculating for
        )
      AND schools.date_created <= dates.date
    GROUP BY
      urn,
      date,
      schools.date_closed,
      schools.date_opened,
      schools.date_created,
      schools.status,
      historic_signups.School_been_added,
      historic_signups.Date_first_signed_up,
      trust.uid)
    # don't calculate metrics for dates that are in the future - they'll just show up as null in the final table
  WHERE
    date <= CURRENT_DATE()
  GROUP BY
    date )
SELECT
  dates.date,
  school_metrics.schools_signed_up,
  goals.Expected_number_of_schools_with_a_user_account_by_this_date AS target_schools_signed_up,
  school_metrics.schools_in_scope,
  SAFE_DIVIDE(school_metrics.schools_signed_up,
    school_metrics.schools_in_scope) AS proportion_of_schools_signed_up,
  goals.Expected___schools_with_a_user_account_by_this_date AS target_proportion_of_schools_signed_up,
  school_metrics.schools_which_published_in_the_last_year AS schools_which_published_vacancies_in_the_last_year,
  school_metrics.schools_which_published_in_the_last_quarter AS schools_which_published_vacancies_in_the_last_quarter,
  school_metrics.schools_which_published_so_far AS schools_which_published_vacancies_so_far,
  school_metrics.schools_which_had_vacancies_live AS schools_which_had_vacancies_live,
  SAFE_DIVIDE(school_metrics.schools_which_published_in_the_last_year,
    school_metrics.schools_in_scope) AS proportion_of_schools_which_published_in_the_last_year,
  SAFE_DIVIDE(school_metrics.schools_which_published_in_the_last_quarter,
    school_metrics.schools_in_scope) AS proportion_of_schools_which_published_in_the_last_quarter,
  SAFE_DIVIDE(school_metrics.schools_which_published_so_far,
    school_metrics.schools_in_scope) AS proportion_of_schools_which_published_so_far,
  SAFE_DIVIDE(school_metrics.schools_which_had_vacancies_live,
    school_metrics.schools_in_scope) AS proportion_of_schools_which_had_vacancies_live,
  SAFE_DIVIDE(school_metrics.schools_which_published_in_the_last_year,
    school_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_in_the_last_year,
  SAFE_DIVIDE(school_metrics.schools_which_published_in_the_last_quarter,
    school_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_in_the_last_quarter,
  SAFE_DIVIDE(school_metrics.schools_which_published_so_far,
    school_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_so_far,
  SAFE_DIVIDE(school_metrics.schools_which_had_vacancies_live,
    school_metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_had_vacancies_live,
FROM
  dates
LEFT JOIN
  school_metrics
USING
  (date)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.nightly_goals_from_google_sheets` AS goals #pull in manually set goals for metrics from a Google Sheet
ON
  dates.date = goals.Date
ORDER BY
  date
