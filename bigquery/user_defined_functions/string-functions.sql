  # Contains useful string processing functions that can be reused across multiple scheduled queries and views in BigQuery.
  # This script must be run in BigQuery for these functions to become available, and re-run to overwrite the available functions with any new version.
  # Take a client user agent from a Cloudfront server log and use it to categorise that traffic into a device category
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.convert_client_user_agent_to_device_category`(client_user_agent STRING)
  RETURNS STRING AS (
    CASE
      WHEN LOWER(client_user_agent) LIKE "%bot%" OR LOWER(client_user_agent) LIKE "%http%" OR LOWER(client_user_agent) LIKE "%python%" OR LOWER(client_user_agent) LIKE "%scan%" OR LOWER(client_user_agent) LIKE "%check%" OR LOWER(client_user_agent) LIKE "%spider%" OR LOWER(client_user_agent) LIKE "%curl%" OR LOWER(client_user_agent) LIKE "%trend%" OR LOWER(client_user_agent) LIKE "%ruby%" OR LOWER(client_user_agent) LIKE "%bash%" OR LOWER(client_user_agent) LIKE "%batch%" OR LOWER(client_user_agent) LIKE "%verification%" OR LOWER(client_user_agent) LIKE "%qwantify%" OR LOWER(client_user_agent) LIKE "%nuclei%" OR LOWER(client_user_agent) LIKE "%ai%" OR LOWER(client_user_agent) LIKE "%crawler%" OR LOWER(client_user_agent) LIKE "%perl%" OR LOWER(client_user_agent) LIKE "%java%" OR LOWER(client_user_agent) LIKE "%test%" OR LOWER(client_user_agent) LIKE "%scoop%" OR LOWER(client_user_agent) LIKE "%fetch%" OR LOWER(client_user_agent) LIKE "%adreview%" OR LOWER(client_user_agent) LIKE "%cortex%" OR LOWER(client_user_agent) LIKE "%nessus%" OR LOWER(client_user_agent) LIKE "%bitdiscovery%" OR LOWER(client_user_agent) LIKE "%postplanner%" OR LOWER(client_user_agent) LIKE "%faraday%" OR LOWER(client_user_agent) LIKE "%restsharp%" OR LOWER(client_user_agent) LIKE "%hootsuite%" OR LOWER(client_user_agent) LIKE "%mattermost%" OR LOWER(client_user_agent) LIKE "%shortlink%" OR LOWER(client_user_agent) LIKE "%retriever%" OR LOWER(client_user_agent) LIKE "%auto%" OR LOWER(client_user_agent) LIKE "%scrper%" OR LOWER(client_user_agent) LIKE "%alyzer%" OR LOWER(client_user_agent) LIKE "%dispatch%" OR LOWER(client_user_agent) LIKE "%traackr%" OR LOWER(client_user_agent) LIKE "%fiddler%" OR LOWER(client_user_agent) LIKE "%crowsnest%" OR LOWER(client_user_agent) LIKE "%gigablast%" OR LOWER(client_user_agent) LIKE "%wakelet%" OR LOWER(client_user_agent) LIKE "%installatron%" OR LOWER(client_user_agent) LIKE "%intently%" OR LOWER(client_user_agent) LIKE "%openurl%" OR LOWER(client_user_agent) LIKE "%anthill%" OR LOWER(client_user_agent) LIKE "%curb%" OR LOWER(client_user_agent) LIKE "%trello%" OR LOWER(client_user_agent) LIKE "%inject%" OR LOWER(client_user_agent) LIKE "%ahc%" THEN "bot"
      WHEN LOWER(client_user_agent) LIKE "%mobile%"
    OR LOWER(client_user_agent) LIKE "%android%"
    OR LOWER(client_user_agent) LIKE "%whatsapp%"
    OR LOWER(client_user_agent) LIKE "%iphone%"
    OR LOWER(client_user_agent) LIKE "%ios%"
    OR LOWER(client_user_agent) LIKE "%tablet%"
    OR LOWER(client_user_agent) LIKE "%samsung%" THEN "mobile"
      WHEN LOWER(client_user_agent) LIKE "%win%" OR LOWER(client_user_agent) LIKE "%mac%" OR LOWER(client_user_agent) LIKE "%x11%" OR LOWER(client_user_agent) LIKE "%linux%" OR LOWER(client_user_agent) LIKE "%opera%" OR LOWER(client_user_agent) LIKE "%whatweb%" OR LOWER(client_user_agent) LIKE "%microsoft%office%2014%" THEN "desktop"
    ELSE
    "unknown"
  END
    );
  # Take various fields from a Cloudfront server log and use them to categorise that traffic into a medium
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.categorise_traffic_by_medium`(utm_campaign STRING,
    utm_medium STRING,
    referrer STRING,
    landing_page_stem STRING)
  RETURNS STRING AS (
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
    );
  # Converts escaped characters in a URL (like '%20') into their actual characters (like ' '), and converts '+' into ' '.
  # Also removes "jobs_search_form","search_criteria" and square brackets from before search parameters to make specific parameter extraction more readable.
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.decode_url_escape_characters`(url STRING) AS (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(url,"%255D",""),"%255B",""),"%252F","/"),"%253F","?"),"%253D","="),"%2526","&"),"+"," "),"%252C",","),"%253A",":"),"jobs_search_form",""),"search_criteria",""));
  # Extracts the value of a specified parameter from within a URL query (the query is the part after the ?)
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(url_query STRING,
    parameter_to_extract STRING)
  RETURNS STRING AS (REGEXP_EXTRACT(url_query,parameter_to_extract || "=([^&]+)") );
  # Remove a specified parameter entirely from a URL query string
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.remove_parameter`(url_query STRING,
    parameter_to_remove STRING) AS (REGEXP_REPLACE(url_query,"([&?]*" || parameter_to_remove || "=[0-9a-zA-Z_%-]+)",""));
  # Redact a specified parameter from a URL query string
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.redact_parameter`(url_query STRING,
    parameter_to_redact STRING) AS (REGEXP_REPLACE(url_query,"(" || parameter_to_redact || "=[0-9a-zA-Z_%-]+)",parameter_to_redact || "=redacted"));
  # Extract important search criteria from a URL query, and concatenate them together separated by 'and' in loose order of importance
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.make_search_parameters_human_readable`(url_query STRING) AS ( ARRAY_TO_STRING([
    IF
      (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(url_query,
          "keyword") IS NULL,
        NULL,
        "keyword"),
    IF
      (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(url_query,
          "location") IS NULL,
        NULL,
        "location"),
    IF
      (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(url_query,
          "job_roles") IS NULL,
        NULL,
        "job_roles"),
    IF
      (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(url_query,
          "phases") IS NULL,
        NULL,
        "phases"),
    IF
      (`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(url_query,
          "working_patterns") IS NULL,
        NULL,
        "working_patterns") ]," and "));
  # Categorise the job title of a vacancy (either TV or crawled) as teacher, leadership, teaching_assistant or NULL
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.categorise_vacancy_job_title`(job_title STRING) AS (
  IF
    (LOWER(job_title) LIKE '%head%'
      OR LOWER(job_title) LIKE '%ordinat%'
      OR LOWER(job_title) LIKE '%principal%',
      "leadership",
    IF
      ((job_title LIKE '%TA%'
          OR job_title LIKE '%TAs%'
          OR LOWER(job_title) LIKE '% assistant%' #picks up teaching assistant, learning support assistant etc.
          OR LOWER(job_title) LIKE '%intervention %')
        AND LOWER(job_title) NOT LIKE '%admin%'
        AND LOWER(job_title) NOT LIKE '%account%'
        AND LOWER(job_title) NOT LIKE '%marketing%'
        AND LOWER(job_title) NOT LIKE '%admission%'
        AND LOWER(job_title) NOT LIKE '%care%',
        "teaching_assistant",
      IF
        (LOWER(job_title) LIKE '%teacher%'
          OR LOWER(job_title) LIKE '%lecturer%',
          "teacher",
          NULL))))
