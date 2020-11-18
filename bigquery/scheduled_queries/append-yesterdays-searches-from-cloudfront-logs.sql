SELECT
  date,
  time,
  device_category,
  #our URLs often don't include a page parameter, in which case we display page 1 of results - this line sets deepest_results_page_viewed to 1 if no parameter was specified in the URL
  IFNULL(CAST(deepest_results_page_viewed AS INT64),
    1) AS deepest_results_page_viewed,
  results_pages_viewed,
  number_of_results_pages_viewed,
  criteria_used,
  keyword,
  #if the location includes a number, assume it contains a postcode and so is PII, so redact it and replace it with the string "postcode"
IF
  (REGEXP_CONTAINS(location,"[0-9]"),
    "postcode",
    location) AS location,
  radius,
  job_roles,
  phases,
  working_patterns,
  jobs_sort,
  #if no vacancies were found with this search as the referrer, then set the number_of_vacancies_opened_from_this_search to 0 so we can calculate averages etc. from this field
  IFNULL(ARRAY_LENGTH(vacancies_opened_from_this_search),
    0) AS number_of_vacancies_opened_from_this_search,
IF
  (ARRAY_LENGTH(vacancies_opened_from_this_search) >= 1,
    TRUE,
    FALSE) AS viewed_a_vacancy,
  #a boolean for quick analysis
  vacancies_opened_from_this_search
FROM (
  SELECT
    date,
    time,
    device_category,
    deepest_results_page_viewed,
    ARRAY(
    SELECT
      DISTINCT *
    FROM
      UNNEST(results_pages_viewed)) AS results_pages_viewed,
    #remove duplicates
    number_of_results_pages_viewed,
    `teacher-vacancy-service.production_dataset.make_search_parameters_human_readable`(search_parameters) AS criteria_used,
    #extract the value of each of these parameters from the query in the logs - unfortunately in SQL there is no easy more abstract way to pull out key-value pairs
    TRIM(LOWER(`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
          "keyword"))) AS keyword,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
      "location") AS location,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
      "radius") AS radius,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
      "job_roles") AS job_roles,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
      "phases") AS phases,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
      "working_patterns") AS working_patterns,
    `teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(search_parameters,
      "jobs_sort") AS jobs_sort,
    (
      #this subquery matches this search to vacancy views in the log, and pulls the slugs together into an array (the slug is a vacancy UID in our db)
    SELECT
      ARRAY_AGG(SPLIT(cs_uri_stem,"/")[ORDINAL(3)]) AS vacancies_opened_from_this_search #extract each slug from the url (after the 2nd / in a URL like .../jobs/slug) and aggregate them into an array
    FROM
      `teacher-vacancy-service.production_dataset.cloudfront_logs`
    WHERE
      cs_referer LIKE "%/jobs?%" #only look at log items referred from a search results page
      AND cs_uri_stem LIKE "/jobs/%" #only look at vacancy views
      AND sc_content_type LIKE "%text/html%" #only look at HTML
      AND `teacher-vacancy-service.production_dataset.make_search_parameters_human_readable`(search.search_parameters)=`teacher-vacancy-service.production_dataset.make_search_parameters_human_readable`(`teacher-vacancy-service.production_dataset.decode_url_escape_characters`(SPLIT(cs_referer,"?")[ORDINAL(2)])) #match the vacancy views to a search in the parent query that has the same search parameters
      AND c_ip=search.c_ip #also require this match to made on IP address
      AND date=search.date #and on date - search parameters (minus page), IP address and date between them provide our UID for the search
    GROUP BY
      c_ip,
      date,
      search_parameters ) AS vacancies_opened_from_this_search
  FROM (
    SELECT
      c_ip,
      #classify each log item as being from mobile, desktop, bot or unknown - this correctly classified over 99.99% of the test week-long dataset (barring intentional fraudulent use of c_user_agent)
      `teacher-vacancy-service.production_dataset.convert_client_user_agent_to_device_category`(c_user_agent) AS device_category,
      date,
      MIN(time) AS time,
      #take the earliest time as the time of this search (relevant for multi-results page searches)
      `teacher-vacancy-service.production_dataset.remove_parameter`(`teacher-vacancy-service.production_dataset.decode_url_escape_characters`(cs_uri_query),
        "page") AS search_parameters,
      #handle strange characters and discard the page parameter so that we can group by search parameters without it
      MAX(`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_uri_query,
          "page")) AS deepest_results_page_viewed,
      #record the highest page number of a results page viewed - note this is not the same as the search depth, because users can jump straight in at a deeper page, skip to the end of the results etc.
      ARRAY_AGG(IFNULL(`teacher-vacancy-service.production_dataset.extract_parameter_from_url_query`(cs_uri_query,
            "page"),
          "1")) AS results_pages_viewed,
      #extract the page number of each results page viewed, and put them all in an array
      COUNT(DISTINCT cs_uri_query) AS number_of_results_pages_viewed #count the total number of results pages viewed for these search parameters and IP on this date
    FROM
      `teacher-vacancy-service.production_dataset.cloudfront_logs`
    WHERE
      cs_uri_stem = "/jobs" #search results all have this stem (vacancies have /jobs/slug)
      AND sc_content_type LIKE "%text/html%" #vacancies must be HTML
    GROUP BY
      c_ip,
      c_user_agent,
      date,
      search_parameters
    HAVING
      device_category != "bot" #filter out searches made by bots
      ) AS search )
WHERE
  #only append searches from yesterday
  date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND (
  SELECT
    MAX(date)
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_searches_from_cloudfront_logs`)<DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) #in case something breaks - don't append anything if it looks like we already appended yesterday's searches
ORDER BY
  date ASC
