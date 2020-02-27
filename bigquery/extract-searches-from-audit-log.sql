SELECT
  created_at AS datetime,
  data_total_count AS results_returned,
  data_subject AS subject,
  id AS id,
  IF(REGEXP_CONTAINS(data_location,"[0-9]"),"postcode",data_location) AS location, #if the location searched for contains a number anywhere, replace it with 'postcode' to anonymise it and allow all postcode searches to be counted together later
  data_radius AS radius,
  ARRAY_TO_STRING(ARRAY(SELECT x FROM UNNEST(data_phases) AS x ORDER BY x)," or ") AS education_phases, #sort the array and then concatenate it into a list separated by 'or' to allow more straightforward reporting later
  data_job_title AS job_title,
  COALESCE(ARRAY_TO_STRING(ARRAY(SELECT x FROM UNNEST(data_working_patterns) AS x ORDER BY x)," or "),data_working_pattern) AS working_patterns, #sort the array and then concatenate it into a list separated by 'or' to allow more straightforward reporting later; also use the old single-value working_pattern field if this has been completed to handle legacy search schema
  data_newly_qualified_teacher AS newly_qualified_teacher,
  data_minimum_salary AS minimum_salary
FROM
  `teacher-vacancy-service.production_dataset.feb20_audit_data`
WHERE
  category="search_event" #the audit table contains different types of events; this just picks out the search events (not vacancy status changes, new job alert subscriptions etc.)
  AND data_total_count IS NOT NULL #exclude some very old junk data
