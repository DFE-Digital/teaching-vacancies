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
    RSC_region
  FROM
    `teacher-vacancy-service.production_dataset.school`
  WHERE
    ((date_closed IS NULL
        AND status != "Closed")
      OR (status = "Closed"
        AND date_closed > '2018-05-03'))
    AND detailed_school_type_in_scope),
  vacancies AS (
  SELECT
    id,
    publish_on,
    expires_on
  FROM
    `teacher-vacancy-service.production_dataset.vacancies_published` ),
  metrics AS (
  SELECT
    date,
    RSC_region,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(in_scope)) AS schools_in_scope,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(signed_up)) AS schools_signed_up,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_so_far)) AS schools_which_published_so_far,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_in_the_last_year)) AS schools_which_published_in_the_last_year,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(has_published_in_the_last_quarter)) AS schools_which_published_in_the_last_quarter,
  IF
    (date > CURRENT_DATE(),
      NULL,
      COUNTIF(had_live_vacancies)) AS schools_which_had_vacancies_live
  FROM (
    SELECT
      schools.urn AS urn,
      dates.date AS date,
      schools.RSC_region AS RSC_region,
    IF
      ((schools.status != "Closed" #if the school is not currently closed
          OR schools.date_closed > dates.date) #or if the school closed after the date we're calculating for
        AND (schools.status != "Proposed to open" #and if the school is not currently proposed to open
          OR schools.date_opened <= dates.date #or if the school opened before the date we're calculating for
          )
        AND schools.date_created <= dates.date,
        #and if the school was first listed on GIAS before or on the date we're calculating for
        TRUE,
        FALSE) AS in_scope,
    IF
      ((schools.status = "Closed"
          AND schools.date_closed <= dates.date)
        OR schools.date_opened > dates.date,
        FALSE,
        #mark schools which were closed or had not yet opened as not signed up, regardless of whether this is before or after 20th November 2019
      IF
        ( historic_signups.School_been_added
          AND dates.date<='2019-11-20',
        IF
          (historic_signups.Date_first_signed_up<dates.date,
            TRUE,
            FALSE),
          #up until 20th November 2019, take signup data from the static table of historic signup data for each school
        IF
          (COUNTIF(users.from_date <= dates.date
              AND (users.to_date IS NULL
                OR users.to_date > dates.date)) >= 1,
            #after 20th November 2019, count the number of users who had access, see if it is 1 or more, and if so count the school as signed up
            TRUE,
            FALSE))) AS signed_up,
    IF
      ((schools.status = "Closed"
          AND schools.date_closed <= dates.date)
        OR schools.date_opened > dates.date,
        FALSE,
        #mark schools which were closed or had not yet opened as not having published
      IF
        (COUNTIF(vacancies.publish_on <= dates.date) > 1,
          TRUE,
          FALSE)) AS has_published_so_far,
    IF
      ((schools.status = "Closed"
          AND schools.date_closed <= dates.date)
        OR schools.date_opened > dates.date,
        FALSE,
        #mark schools which were closed or had not yet opened as not having published in the last year
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 1 YEAR)) > 1,
          TRUE,
          FALSE)) AS has_published_in_the_last_year,
    IF
      ((schools.status = "Closed"
          AND schools.date_closed <= dates.date)
        OR schools.date_opened > dates.date,
        FALSE,
        #mark schools which were closed or had not yet opened as not having published in the last quarter
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.publish_on >= DATE_SUB(dates.date,INTERVAL 3 MONTH)) > 1,
          TRUE,
          FALSE)) AS has_published_in_the_last_quarter,
    IF
      ((schools.status = "Closed"
          AND schools.date_closed <= dates.date)
        OR schools.date_opened > dates.date,
        FALSE,
        #mark schools which were closed or had not yet opened as not having had live vacancies
      IF
        (COUNTIF(vacancies.publish_on <= dates.date
            AND vacancies.expires_on > dates.date) > 1,
          TRUE,
          FALSE)) AS had_live_vacancies
    FROM
      schools
    CROSS JOIN
      dates
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.STATIC_schools_historic_pre201119` AS historic_signups
    ON
      CAST(historic_signups.URN AS STRING) = schools.urn
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users` AS users
    ON
      CAST(users.school_urn AS STRING) = schools.urn
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
    ON
      schools.id=organisationvacancy.organisation_id
    LEFT JOIN
      vacancies
    ON
      vacancies.id=organisationvacancy.vacancy_id
    GROUP BY
      urn,
      date,
      RSC_region,
      date_closed,
      date_opened,
      date_created,
      schools.status,
      historic_signups.School_been_added,
      historic_signups.Date_first_signed_up)
  GROUP BY
    date,
    RSC_region )
SELECT
  dates.date,
  metrics.RSC_region,
  metrics.schools_signed_up,
  goals.Expected_number_of_schools_with_a_user_account_by_this_date AS target_schools_signed_up,
  metrics.schools_in_scope,
  SAFE_DIVIDE(metrics.schools_signed_up,
    metrics.schools_in_scope) AS proportion_of_schools_signed_up,
  goals.Expected___schools_with_a_user_account_by_this_date AS target_proportion_of_schools_signed_up,
  metrics.schools_which_published_in_the_last_year AS schools_which_published_vacancies_in_the_last_year,
  metrics.schools_which_published_in_the_last_quarter AS schools_which_published_vacancies_in_the_last_quarter,
  metrics.schools_which_published_so_far AS schools_which_published_vacancies_so_far,
  metrics.schools_which_had_vacancies_live AS schools_which_had_vacancies_live,
  SAFE_DIVIDE(metrics.schools_which_published_in_the_last_year,
    metrics.schools_in_scope) AS proportion_of_schools_which_published_in_the_last_year,
  SAFE_DIVIDE(metrics.schools_which_published_in_the_last_quarter,
    metrics.schools_in_scope) AS proportion_of_schools_which_published_in_the_last_quarter,
  SAFE_DIVIDE(metrics.schools_which_published_so_far,
    metrics.schools_in_scope) AS proportion_of_schools_which_published_so_far,
  SAFE_DIVIDE(metrics.schools_which_had_vacancies_live,
    metrics.schools_in_scope) AS proportion_of_schools_which_had_vacancies_live,
  SAFE_DIVIDE(metrics.schools_which_published_in_the_last_year,
    metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_in_the_last_year,
  SAFE_DIVIDE(metrics.schools_which_published_in_the_last_quarter,
    metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_in_the_last_quarter,
  SAFE_DIVIDE(metrics.schools_which_published_so_far,
    metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_published_so_far,
  SAFE_DIVIDE(metrics.schools_which_had_vacancies_live,
    metrics.schools_signed_up) AS proportion_of_signed_up_schools_which_had_vacancies_live,
FROM
  dates
LEFT JOIN
  metrics
USING
  (date)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.nightly_goals_from_google_sheets` AS goals #pull in manually set goals for metrics from a Google Sheet
ON
  dates.date = goals.Date
ORDER BY
  date
