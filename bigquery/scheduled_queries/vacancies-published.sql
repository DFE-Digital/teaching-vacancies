WITH
  vacancies_published_with_cumulative AS ( #we'll need to join this to itself later - so defining it only once here to avoid repetition
  SELECT
    month,
    vacancies_published,
    SUM(vacancies_published) OVER (PARTITION BY academic_year ORDER BY month) AS vacancies_published_so_far_this_AY,
  FROM (
      # this sub query produces a table of months and their academic years, along with the number of vacancies published in each month
    SELECT
      COUNT(*) AS vacancies_published,
      month,
    IF
      ( month < DATE_ADD(year,INTERVAL 8 MONTH),
        DATE_SUB(year,INTERVAL 4 MONTH),
        DATE_ADD(year,INTERVAL 8 MONTH)) AS academic_year #converts the month into the corresponding academic year, storing this as the 1st September at the beginning of that academic year (the precise format doesn't matter; we just need a consistent way to represent the academic year so that the PARTITION BY above works)
    FROM (
      SELECT
        DATE_TRUNC(publish_on,MONTH) AS month,
        #use the first day of the month containing publish_on to represent the month (standard in data studio)
        DATE_TRUNC(publish_on,YEAR) AS year #use the first day of the year containing publish_on to represent the year (standard in data studio)
      FROM
        `teacher-vacancy-service.production_dataset.vacancies_published`
      WHERE
        publish_on IS NOT NULL #also excludes vacancies which were never published (to be safe)
        AND publish_on <= CURRENT_DATE() ) #excludes vacancies which have been published but are not yet visible on the site because their publication date is in the future
    GROUP BY
      month,
      year
    ORDER BY
      month ASC )
  GROUP BY
    month,
    academic_year,
    vacancies_published
  ORDER BY
    month ASC )
SELECT
  COALESCE(vacancies_published_with_cumulative.month,
    goals.Month) AS month,
  #get the month from the vacancies table if possible - but if not take it from the goals Google sheet
  vacancies_published_with_cumulative.vacancies_published,
  vacancies_published_with_cumulative.vacancies_published_so_far_this_AY,
  COALESCE(goals.COVID_adjusted_vacancies_listed,
    vacancies_published_with_cumulative.vacancies_published) AS vacancies_published_COVID_adjusted,
  COALESCE(vacancies_published_with_cumulative_shifted.vacancies_published,
    vacancies_published_with_cumulative_shifted_duplicate.vacancies_published) AS vacancies_published_last_AY,
  COALESCE(vacancies_published_with_cumulative_shifted.vacancies_published_so_far_this_AY,
    vacancies_published_with_cumulative_shifted_duplicate.vacancies_published_so_far_this_AY) AS vacancies_published_so_far_last_AY,
  SAFE_DIVIDE(vacancies_published_with_cumulative.vacancies_published,
    COALESCE(vacancies_published_with_cumulative_shifted.vacancies_published,
      vacancies_published_with_cumulative_shifted_duplicate.vacancies_published))-1 AS proportional_change_in_vacancies_published_since_last_AY,
  SAFE_DIVIDE(vacancies_published_with_cumulative.vacancies_published,
    COALESCE(goals.COVID_adjusted_vacancies_listed,
      COALESCE(vacancies_published_with_cumulative_shifted.vacancies_published,
        vacancies_published_with_cumulative_shifted_duplicate.vacancies_published)))-1 AS proportional_change_in_vacancies_published_since_last_AY_COVID_adjusted,
  goals.Target_vacancies_listed,
  goals.Target_total_vacancies_listed AS Target_total_vacancies_listed_this_AY
FROM
  vacancies_published_with_cumulative
FULL JOIN ( #Miss out all blank rows from the Google Sheet, and then join on the goals columns to the table
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.monthly_goals_from_google_sheets`
  WHERE
    Month IS NOT NULL) AS goals
ON
  goals.Month = vacancies_published_with_cumulative.month
LEFT JOIN
  #join the table of vacancies published / published so far this AY on to itself 1 year previously to allow us to create fields for *last* academic year that have values in for past months
  vacancies_published_with_cumulative AS vacancies_published_with_cumulative_shifted
ON
  DATE_ADD(vacancies_published_with_cumulative_shifted.month, INTERVAL 1 YEAR)=vacancies_published_with_cumulative.month
LEFT JOIN
  #join the table of vacancies published / published so far this AY on to itself 1 year previously *again* to allow us to create fields for *last* academic year that have values in for months we have a goal value set for
  vacancies_published_with_cumulative AS vacancies_published_with_cumulative_shifted_duplicate
ON
  DATE_ADD(vacancies_published_with_cumulative_shifted_duplicate.month, INTERVAL 1 YEAR)=goals.Month
ORDER BY
  month ASC
