SELECT
  date,
  slug,
  MAX(unique_views) AS unique_views #if the latest unique_downloads of a particular document on a particular day in the Google Sheet from GA differs from the version we have in the table already, take the higher of the two values
FROM (
  SELECT
    Date AS date,
    SPLIT(TRIM(Page_path_level_2,"/"),"?")[ORDINAL(1)] AS slug,
    #remove the / from the front of the path and strip out any parameters after a ? to convert the level 2 path into the vacancy slug
    Unique_Events AS unique_views
  FROM
    `teacher-vacancy-service.production_dataset.GA_vacancies_viewed_each_day` AS latest_table
  WHERE
    Date IS NOT NULL
  UNION ALL
  SELECT
    date,
    slug,
    unique_views
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_vacancies_viewed_each_day` AS previous_table
)
GROUP BY
  date,
  slug
