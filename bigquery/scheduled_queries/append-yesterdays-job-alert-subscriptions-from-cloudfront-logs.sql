SELECT
  date,
  time,
  device_category,
IF
  (REGEXP_CONTAINS(cs_referer,"[?&]origin=/jobs/([^&?]+)"),
    "vacancy",
    "search") AS route_to_job_alert,
  REGEXP_EXTRACT(cs_referer,"[?&]origin=/jobs/([^&?]+)") AS listing_page_clicked_job_alert_link_on,
  `teacher-vacancy-service.production_dataset.make_search_parameters_human_readable`(cs_referer) AS criteria_used,
  #extract the value of each of these parameters from the query in the logs
  TRIM(LOWER(`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
        "keyword"))) AS keyword,
IF
  (REGEXP_CONTAINS(`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
        "location"),"[0-9]"),
    "postcode",
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
      "location")) AS location,
  `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
    "radius") AS radius,
  `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
    "job_roles") AS job_roles,
  `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
    "phases") AS phases,
  `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_referer,
    "working_patterns") AS working_patterns,
FROM (
  SELECT
    date,
    time,
    c_ip,
    `teacher-vacancy-service.production_dataset.decode_url_escape_characters`(cs_referer) AS cs_referer,
    `teacher-vacancy-service.production_dataset.convert_client_user_agent_to_device_category`(c_user_agent) AS device_category,
  FROM
    `teacher-vacancy-service.production_dataset.cloudfront_logs`
  WHERE
    cs_method="POST"
    AND cs_uri_stem="/subscriptions"
    AND sc_status="200"
    AND sc_content_type LIKE "%text/html%" AND   #only append job alert subscriptions from yesterday
    date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    AND (
    SELECT
      MAX(date)
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_job_alerts_created_from_cloudfront_logs`)<DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) #in case something breaks - don't append anything if it looks like we already appended yesterday's job alert subscriptions
    )
WHERE
  device_category != "bot"
ORDER BY
  date ASC
