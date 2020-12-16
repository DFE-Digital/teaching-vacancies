  # Contains useful string processing functions that can be reused across multiple scheduled queries and views in BigQuery.
  # This script must be run in BigQuery for these functions to become available, and re-run to overwrite the available functions with any new version.
  # Take a client user agent from a Cloudfront server log and use it to categorise that traffic into a device category
CREATE OR REPLACE FUNCTION
  `teacher-vacancy-service.production_dataset.convert_client_user_agent_to_device_category`(client_user_agent STRING)
  RETURNS STRING AS (
    CASE
      WHEN REGEXP_CONTAINS(client_user_agent, "(?i)(bot|http|python|scan|check|spider|curl|trend|ruby|bash|batch|verification|qwantify|nuclei|ai|crawler|perl|java|test|scoop|fetch|adreview|cortex|nessus|bitdiscovery|postplanner|faraday|restsharp|hootsuite|mattermost|shortlink|retriever|auto|scrper|alyzer|dispatch|traackr|fiddler|crowsnest|gigablast|wakelet|installatron|intently|openurl|anthill|curb|trello|inject|ahc|sleep|sysdate|=|cloudinary)") THEN "bot"
      WHEN REGEXP_CONTAINS(client_user_agent, "(?i)(mobile|android|whatsapp|iphone|ios|tablet|samsung)") THEN "mobile"
      WHEN REGEXP_CONTAINS(client_user_agent, "(?i)(win|mac|x11|linux|opera|whatweb|office|MSIE)") THEN "desktop"
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
      WHEN REGEXP_CONTAINS(utm_campaign,"(alert)") THEN "Job alert"
      WHEN REGEXP_CONTAINS(utm_medium,"(?i)(email)") THEN "Email"
      WHEN REGEXP_CONTAINS(referrer,"(?i)(facebook|twitter|t.co|linkedin|youtube)") THEN "Social"
      WHEN (referrer IS NOT NULL
      AND NOT REGEXP_CONTAINS(referrer,"(teaching-jobs.service.gov.uk|teaching-vacancies.service.gov.uk|google|bing|yahoo|aol|ask.co|baidu|duckduckgo)")
      OR utm_medium="referral") THEN "Referral"
      WHEN utm_medium = "cpc" THEN "PPC"
      WHEN REGEXP_CONTAINS(referrer,"(google|bing|yahoo|aol|ask.co|baidu|duckduckgo)")
    OR utm_medium="organic" THEN (CASE
        WHEN landing_page_stem = "/" THEN "Organic - to home page"
        WHEN landing_page_stem LIKE "/jobs/%" THEN "Organic - to listing (e.g. Google Jobs)"
        WHEN landing_page_stem LIKE "/teaching-jobs%" THEN "Organic - to landing page"
      ELSE
      "Organic - other"
    END
      )
     WHEN REGEXP_CONTAINS(referrer,"(teaching-jobs.service.gov.uk|teaching-vacancies.service.gov.uk)") THEN "Unknown"
    ELSE
    "Direct or unknown"
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
    CASE
      WHEN REGEXP_CONTAINS(job_title,"(?i)(head|ordinat|principal)") THEN "leadership"
      WHEN (REGEXP_CONTAINS(job_title,"(TA)")
      OR REGEXP_CONTAINS(job_title,"(?i)( assistant|intervention )") #picks up teaching assistant, learning support assistant etc. as well as TAs
      )
    AND NOT REGEXP_CONTAINS(job_title,"(?i)(admin|account|marketing|admission|care)") THEN "teaching_assistant"
      WHEN REGEXP_CONTAINS(job_title,"(?i)(teacher|lecturer)") THEN "teacher"
    ELSE
    NULL
  END
    )
