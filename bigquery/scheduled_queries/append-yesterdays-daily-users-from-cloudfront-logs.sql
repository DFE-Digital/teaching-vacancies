SELECT
  date,
  time,
  type,
  device_category,
  search_parameters,
  vacancies_viewed_slugs,
  vacancies_with_gmi_clicks_ids,
  utm_sources,
  utm_campaigns,
  utm_mediums,
  job_alert_destination_links,
  job_alert_destinations,
  referrers,
  vacancies_viewed_slugs IS NOT NULL AS viewed_a_vacancy,
  vacancies_with_gmi_clicks_ids IS NOT NULL AS clicked_get_more_information,
  "subscription" IN UNNEST(utm_sources) AS from_job_alert,
  ARRAY_LENGTH(search_parameters) AS unique_searches,
  ARRAY_LENGTH(vacancies_viewed_slugs) AS vacancies_viewed,
  ARRAY_LENGTH(vacancies_with_gmi_clicks_ids) AS vacancies_with_gmi_clicks
FROM (
  SELECT
    date,
    MIN(time) AS time,
    c_ip,
  IF
    (LOGICAL_OR(cs_uri_stem LIKE "/organisation%"),
      "hiring staff",
      "jobseeker") AS type,
    ARRAY_AGG(DISTINCT
    IF
      (cs_uri_stem = "/jobs"
        AND cs_uri_query != "-",
        REGEXP_REPLACE(REGEXP_REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cs_uri_query,"jobs_search_form",""),"%255D",""),"%255B",""),"+"," "),"%252C",","),"location=([^&]+)","location=redacted"),"(&page=[0-9+])",""),
        NULL) IGNORE NULLS) AS search_parameters,
    ARRAY_AGG(DISTINCT
    IF
      (cs_uri_stem NOT LIKE "%/interests/new%",
        REGEXP_EXTRACT(cs_uri_stem,r'^/jobs/([^/?]+)'),
        NULL) IGNORE NULLS) AS vacancies_viewed_slugs,
    ARRAY_AGG(DISTINCT REGEXP_EXTRACT(cs_uri_stem,"^/jobs/(.+)/interests/new") IGNORE NULLS) AS vacancies_with_gmi_clicks_ids,
    ARRAY_AGG(DISTINCT REGEXP_EXTRACT(cs_uri_query,"utm_source=([^&]+)") IGNORE NULLS) AS utm_sources,
    ARRAY_AGG(DISTINCT REGEXP_EXTRACT(cs_uri_query,"utm_campaign=([^&]+)") IGNORE NULLS) AS utm_campaigns,
    ARRAY_AGG(DISTINCT REGEXP_EXTRACT(cs_uri_query,"utm_medium=([^&]+)") IGNORE NULLS) AS utm_mediums,
    ARRAY_AGG(DISTINCT
    IF
      (cs_uri_query LIKE "%utm_source=subscription%",
        cs_uri_stem,
        NULL) IGNORE NULLS) AS job_alert_destination_links,
    ARRAY_AGG(DISTINCT
    IF
      (cs_uri_query LIKE "%utm_source=subscription%",
        CASE
          WHEN cs_uri_stem LIKE "/jobs/%" THEN "vacancy"
          WHEN cs_uri_stem LIKE "/subscriptions/%/edit" THEN "edit"
          WHEN cs_uri_stem LIKE "/subscriptions/%/unsubscribe" THEN "unsubscribe"
        ELSE
        "unknown"
      END
        ,
        NULL) IGNORE NULLS) AS job_alert_destinations,
    ARRAY_AGG(DISTINCT
    IF
      (cs_referer NOT LIKE "%teaching-vacancies.service.gov.uk/%"
        AND cs_referer NOT LIKE "%signin.education.gov.uk%"
        AND cs_referer != "-",
        cs_referer,
        NULL) IGNORE NULLS) AS referrers,
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
  GROUP BY
    date,
    c_ip,
    c_user_agent )
WHERE
  device_category != "bot" AND
  #only append users from yesterday
  date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND (
  SELECT
    MAX(date)
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_job_alerts_created_from_cloudfront_logs`)<DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) #in case something breaks - don't append anything if it looks like we already appended yesterday's users
ORDER BY
  date ASC
