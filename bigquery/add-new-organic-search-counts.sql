SELECT
  DISTINCT *
FROM (
  SELECT
    PARSE_DATE("%E4Y%m%d",
      CAST(Date AS STRING)) AS date,
    Device_category AS device,
    Organic_Searches AS organic_searches
  FROM
    `teacher-vacancy-service.production_dataset.GA_tracked_organic_searches`
  WHERE
    Date IS NOT NULL
  UNION ALL
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.GA_tracked_organic_searches_historic`
  WHERE
    Date IS NOT NULL) ORDER BY date,device
