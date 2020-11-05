  #Recalculates the table of monthly users taken from Cloudfront logs for each monthly user within this month,
  #and appends that to monthly users from previous months (which won't change over the course of the month).
  #Should overwrite the CALCULATED_monthly_users_from_cloudfront_logs table daily to accomplish this.
WITH
  cloudfront_logs AS (
  SELECT
    DATE_TRUNC(date, MONTH) AS month,
    DATETIME(date,
      time) AS datetime,
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
    #only append users from last month (if it's the first day of the month) or this month (for days 2-31)
    DATE_TRUNC(date, MONTH) = DATE_TRUNC(CURRENT_DATE() - 1, MONTH) ) (
  SELECT
    month,
    type,
    device_category,
    search_parameters,
    vacancies_viewed_slugs,
    vacancies_with_gmi_clicks_ids,
    utm_source,
    utm_campaign,
    utm_medium,
    job_alert_destination_links,
    job_alert_destinations,
    viewed_a_vacancy,
    clicked_get_more_information,
    from_job_alert,
    unique_searches,
    vacancies_viewed,
    vacancies_with_gmi_clicks,
    referrer,
    landing_page_stem,
    landing_page_query,
    CASE
      WHEN utm_campaign LIKE "%alert%" THEN "Job alert"
      WHEN LOWER(utm_medium) LIKE "%email%" THEN "Email"
      WHEN referrer LIKE "%facebook%" OR referrer LIKE "%twitter%" OR referrer LIKE "%t.co%" OR referrer LIKE "%linkedin%" OR referrer LIKE "%youtube%" THEN "Social"
      WHEN (referrer IS NOT NULL
      AND referrer NOT LIKE "%teaching-jobs.service.gov.uk%"
      AND referrer NOT LIKE "%teaching-vacancies.service.gov.uk%"
      AND referrer NOT LIKE "%google%"
      AND referrer NOT LIKE "%bing%"
      AND referrer NOT LIKE "%yahoo%"
      AND referrer NOT LIKE "%aol%"
      AND referrer NOT LIKE "%ask.co%")
    OR utm_medium="referral" THEN "Referral"
      WHEN utm_medium = "cpc" THEN "PPC"
      WHEN referrer LIKE "%google%"
    OR referrer LIKE "%bing%"
    OR referrer LIKE "%yahoo%"
    OR referrer LIKE "%aol"
    OR referrer LIKE "%ask.co%"
    OR utm_medium="organic" THEN (CASE
        WHEN landing_page_stem = "/" THEN "Organic - to home page"
        WHEN landing_page_stem LIKE "/jobs/%" THEN "Organic - to listing (e.g. Google Jobs)"
        WHEN landing_page_stem LIKE "/teaching-jobs%" THEN "Organic - to landing page"
      ELSE
      "Organic - other"
    END
      )
    ELSE
    "Direct"
  END
    AS medium,
    created_job_alert,
  FROM (
    SELECT
      all_logs.month,
      type,
      device_category,
      search_parameters,
      vacancies_viewed_slugs,
      vacancies_with_gmi_clicks_ids,
      REGEXP_EXTRACT(first_page.query,"utm_source=([^&]+)") AS utm_source,
      REGEXP_EXTRACT(first_page.query,"utm_campaign=([^&]+)") AS utm_campaign,
      REGEXP_EXTRACT(first_page.query,"utm_medium=([^&]+)") AS utm_medium,
      job_alert_destination_links,
      job_alert_destinations,
      vacancies_viewed_slugs IS NOT NULL AS viewed_a_vacancy,
      vacancies_with_gmi_clicks_ids IS NOT NULL AS clicked_get_more_information,
      first_page.query LIKE "%utm_campaign=%alert%" AS from_job_alert,
      ARRAY_LENGTH(search_parameters) AS unique_searches,
      ARRAY_LENGTH(vacancies_viewed_slugs) AS vacancies_viewed,
      ARRAY_LENGTH(vacancies_with_gmi_clicks_ids) AS vacancies_with_gmi_clicks,
    IF
      (first_page.referrer="-",
        NULL,
        first_page.referrer) AS referrer,
      first_page.stem AS landing_page_stem,
      first_page.query AS landing_page_query,
      created_job_alert
    FROM (
      SELECT
        month,
        c_ip,
        c_user_agent,
      IF
        (LOGICAL_OR(cs_uri_stem LIKE "/organisation%"),
          "hiring staff",
          "jobseeker") AS type,
        COUNTIF(cs_uri_stem = "/subscriptions") > 0 AS created_job_alert,
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
        ARRAY_AGG(DISTINCT
        IF
          (cs_uri_query LIKE "%utm_campaign=%alert%",
            cs_uri_stem,
            NULL) IGNORE NULLS) AS job_alert_destination_links,
        ARRAY_AGG(DISTINCT
        IF
          (cs_uri_query LIKE "%utm_campaign=%alert%",
            CASE
              WHEN cs_uri_stem LIKE "/jobs/%" THEN "vacancy"
              WHEN cs_uri_stem LIKE "/subscriptions/%/edit%" THEN "edit"
              WHEN cs_uri_stem LIKE "/subscriptions/%/unsubscribe%" THEN "unsubscribe"
            ELSE
            "unknown"
          END
            ,
            NULL) IGNORE NULLS) AS job_alert_destinations,
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
        AS device_category
      FROM
        cloudfront_logs
      GROUP BY
        month,
        c_ip,
        c_user_agent ) AS all_logs
    LEFT JOIN (
      SELECT
        DISTINCT c_ip,
        month,
        c_user_agent,
        FIRST_VALUE(cs_referer) OVER (PARTITION BY c_ip, month, c_user_agent ORDER BY datetime) AS referrer,
        FIRST_VALUE(cs_uri_stem) OVER (PARTITION BY c_ip, month, c_user_agent ORDER BY datetime) AS stem,
        FIRST_VALUE(cs_uri_query) OVER (PARTITION BY c_ip, month, c_user_agent ORDER BY datetime) AS query
      FROM
        cloudfront_logs
      WHERE
        sc_content_type LIKE "%text/html%") AS first_page
    ON
      all_logs.c_ip=first_page.c_ip
      AND all_logs.month=first_page.month
      AND all_logs.c_user_agent=first_page.c_user_agent )
  WHERE
    device_category != "bot")
UNION ALL (
  SELECT
    month,
    type,
    device_category,
    search_parameters,
    vacancies_viewed_slugs,
    vacancies_with_gmi_clicks_ids,
    utm_source,
    utm_campaign,
    utm_medium,
    job_alert_destination_links,
    job_alert_destinations,
    viewed_a_vacancy,
    clicked_get_more_information,
    from_job_alert,
    unique_searches,
    vacancies_viewed,
    vacancies_with_gmi_clicks,
    referrer,
    landing_page_stem,
    landing_page_query,
    medium,
    created_job_alert
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_monthly_users_from_cloudfront_logs`
  WHERE
    month < DATE_TRUNC(CURRENT_DATE() - 1, MONTH) ) #keep monthly user data that we're not recalculating in the other half of the UNION ALL
ORDER BY
  month ASC
