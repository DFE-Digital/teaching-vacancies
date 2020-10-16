SELECT
  *,
  ARRAY_TO_STRING([
  IF
    (keyword IS NULL,
      NULL,
      "keyword"),
  IF
    (location IS NULL,
      NULL,
      "location"),
  IF
    (job_roles IS NULL,
      NULL,
      "job_roles"),
  IF
    (phases IS NULL,
      NULL,
      "phases"),
  IF
    (working_patterns IS NULL,
      NULL,
      "working_patterns") ]," and ") AS criteria_used
FROM (
  SELECT
    date,
    time,
    device_category,
  IF
    (REGEXP_CONTAINS(cs_referer,"[?&]origin=/jobs/([^&?]+)"),
      "vacancy",
      "search") AS route_to_job_alert,
    REGEXP_EXTRACT(cs_referer,"[?&]origin=/jobs/([^&?]+)") AS listing_page_clicked_job_alert_link_on,
    #extract the value of each of these parameters from the query in the logs
    TRIM(LOWER(REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[keyword\]=([^&]+)'))) AS keyword,
  IF
    (REGEXP_CONTAINS(REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[location\]=([^&]+)'),"[0-9]"),
      "postcode",
      REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[location\]=([^&]+)')) AS location,
    REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[radius\]=([^&]+)') AS radius,
    REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[job_roles\]\[\]=([^&]+)') AS job_roles,
    REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[phases\]\[\]=([^&]+)') AS phases,
    REGEXP_EXTRACT(cs_referer,r'[?&]search_criteria\[working_patterns\]=([^&]+)') AS working_patterns,
  FROM (
    SELECT
      date,
      time,
      c_ip,
      REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cs_referer,"%255B","["),"%255D","]"),"%252F","/"),"%253F","?"),"%253D","="),"%2526","&"),"+"," "),"%253a",":"),"%252c",",") AS cs_referer,
      CASE
        WHEN LOWER(c_user_agent) LIKE "%bot%" OR LOWER(c_user_agent) LIKE "%http%" OR LOWER(c_user_agent) LIKE "%python%" OR LOWER(c_user_agent) LIKE "%scan%" OR LOWER(c_user_agent) LIKE "%check%" OR LOWER(c_user_agent) LIKE "%spider%" OR LOWER(c_user_agent) LIKE "%curl%" OR LOWER(c_user_agent) LIKE "%trend%" OR LOWER(c_user_agent) LIKE "%fetch%" THEN "bot"
        WHEN LOWER(c_user_agent) LIKE "%mobile%"
      OR LOWER(c_user_agent) LIKE "%android%"
      OR LOWER(c_user_agent) LIKE "%whatsapp%"
      OR LOWER(c_user_agent) LIKE "%iphone%"
      OR LOWER(c_user_agent) LIKE "%ios%"
      OR LOWER(c_user_agent) LIKE "%samsung%" THEN "mobile"
        WHEN LOWER(c_user_agent) LIKE "%win%" OR LOWER(c_user_agent) LIKE "%mac%" OR LOWER(c_user_agent) LIKE "%x11%" THEN "desktop"
      ELSE
      "unknown"
    END
      AS device_category,
    FROM
      `teacher-vacancy-service.production_dataset.cloudfront_logs`
    WHERE
      cs_method="POST"
      AND cs_uri_stem="/subscriptions"
      AND sc_status="200"
      AND sc_content_type LIKE "%text/html%" ))
WHERE
  device_category != "bot" AND
  #only append job alert subscriptions from yesterday
  date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND (
  SELECT
    MAX(date)
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_job_alerts_created_from_cloudfront_logs`)<DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) #in case something breaks - don't append anything if it looks like we already appended yesterday's job alert subscriptions
ORDER BY
  date ASC
