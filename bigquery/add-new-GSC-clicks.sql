SELECT
  DISTINCT *
FROM (
  SELECT
    Date AS date,
    LOWER(Device) AS device,
    Clicks AS clicks
  FROM
    `teacher-vacancy-service.production_dataset.GSC_google_search_clicks_from_google_sheets`
  WHERE
    date IS NOT NULL
  UNION ALL
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.GSC_google_search_clicks_historic`
  WHERE
    Date IS NOT NULL )
ORDER BY
  date,
  device
