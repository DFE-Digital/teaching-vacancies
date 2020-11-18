WITH
  cloudfront_logs AS (
  SELECT
    date,
    time,
    #field names from server log table - c denotes 'client'; cs denotes 'client to server'; sc denotes 'server to client'
    c_ip,
    cs_uri_stem,
    cs_referer,
    c_user_agent,
    cs_uri_query,
    sc_content_type
  FROM
    `teacher-vacancy-service.production_dataset.cloudfront_logs`
  WHERE
    #only append users from yesterday
    date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
    AND (
    SELECT
      MAX(date)
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_daily_users_from_cloudfront_logs`) < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) #in case something breaks - don't append anything if it looks like we already appended yesterday's users
    )
SELECT
  *,
  `teacher-vacancy-service.production_dataset.categorise_traffic_by_medium`(utm_campaign,
    utm_medium,
    referrer,
    landing_page_stem) AS medium,
  IFNULL(utm_campaign LIKE "%alert%",
    FALSE) AS from_job_alert
FROM (
  SELECT
    all_logs.date,
    first_page.time,
    type,
    number_of_unique_pageviews,
    number_of_unique_pageviews <= 1 AS bounced,
    created_job_alert,
    device_category,
    search_parameters,
    vacancies_viewed_slugs,
    vacancies_with_gmi_clicks_ids,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(first_page.query,
      "utm_source") AS utm_source,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(first_page.query,
      "utm_campaign") AS utm_campaign,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(first_page.query,
      "utm_medium") AS utm_medium,
    job_alert_destination_links,
    job_alert_destinations,
    vacancies_viewed_slugs IS NOT NULL AS viewed_a_vacancy,
    vacancies_with_gmi_clicks_ids IS NOT NULL AS clicked_get_more_information,
    ARRAY_LENGTH(search_parameters) AS unique_searches,
    ARRAY_LENGTH(vacancies_viewed_slugs) AS vacancies_viewed,
    ARRAY_LENGTH(vacancies_with_gmi_clicks_ids) AS vacancies_with_gmi_clicks,
  IF
    (first_page.referrer="-",
      NULL,
      first_page.referrer) AS referrer,
    first_page.stem AS landing_page_stem,
    first_page.query AS landing_page_query
  FROM (
    SELECT
      date,
      MIN(time) AS time,
      c_ip,
      c_user_agent,
    IF
      (LOGICAL_OR(cs_uri_stem LIKE "/organisation%"),
        "hiring staff",
        "jobseeker") AS type,
      COUNT(DISTINCT CONCAT(cs_uri_stem,cs_uri_query)) AS number_of_unique_pageviews,
      COUNTIF(cs_uri_stem = "/subscriptions") > 0 AS created_job_alert,
      ARRAY_AGG(DISTINCT
      IF
        (cs_uri_stem = "/jobs"
          AND cs_uri_query != "-",
          `teacher-vacancy-service.production_dataset.redact_parameter`( `teacher-vacancy-service.production_dataset.decode_url_escape_characters`( `teacher-vacancy-service.production_dataset.remove_parameter`(cs_uri_query,
                "page")),
            "location"),
          NULL) IGNORE NULLS) AS search_parameters,
      ARRAY_AGG(DISTINCT
      IF
        (cs_uri_stem NOT LIKE "%/interests/new%",
          REGEXP_EXTRACT(cs_uri_stem,r'^/jobs/([^/?]+)'),
          NULL) IGNORE NULLS) AS vacancies_viewed_slugs,
      ARRAY_AGG(DISTINCT REGEXP_EXTRACT(cs_uri_stem,"^/jobs/(.+)/interests/new") IGNORE NULLS) AS vacancies_with_gmi_clicks_ids,
      ARRAY_AGG(DISTINCT
      IF
        (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_uri_query,
            "utm_campaign") LIKE "%alert%",
          cs_uri_stem,
          NULL) IGNORE NULLS) AS job_alert_destination_links,
      ARRAY_AGG(DISTINCT
      IF
        (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_uri_query,
            "utm_campaign") LIKE "%alert%",
          CASE
            WHEN cs_uri_stem LIKE "/jobs/%" THEN "vacancy"
            WHEN cs_uri_stem LIKE "/subscriptions/%/edit%" THEN "edit"
            WHEN cs_uri_stem LIKE "/subscriptions/%/unsubscribe%" THEN "unsubscribe"
          ELSE
          "unknown"
        END
          ,
          NULL) IGNORE NULLS) AS job_alert_destinations,
      `teacher-vacancy-service.production_dataset.convert_client_user_agent_to_device_category`(c_user_agent) AS device_category
    FROM
      cloudfront_logs
    GROUP BY
      date,
      c_ip,
      c_user_agent ) AS all_logs
  LEFT JOIN (
    SELECT
      DISTINCT c_ip,
      date,
      c_user_agent,
      FIRST_VALUE(time) OVER (PARTITION BY c_ip, date, c_user_agent ORDER BY time) AS time,
      FIRST_VALUE(cs_referer) OVER (PARTITION BY c_ip, date, c_user_agent ORDER BY time) AS referrer,
      FIRST_VALUE(cs_uri_stem) OVER (PARTITION BY c_ip, date, c_user_agent ORDER BY time) AS stem,
      FIRST_VALUE(cs_uri_query) OVER (PARTITION BY c_ip, date, c_user_agent ORDER BY time) AS query
    FROM
      cloudfront_logs
    WHERE
      sc_content_type LIKE "%text/html%") AS first_page
  ON
    all_logs.c_ip=first_page.c_ip
    AND all_logs.date=first_page.date
    AND all_logs.c_user_agent=first_page.c_user_agent )
WHERE
  device_category != "bot"
ORDER BY
  date ASC
