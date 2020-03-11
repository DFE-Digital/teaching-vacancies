SELECT
  *,
  RTRIM(CONCAT(
  IF
    (location IS NOT NULL,
      CONCAT("location, "),
      ""),
  IF
    (subject IS NOT NULL,
      CONCAT("subject, "),
      ""),
  IF
    (job_title IS NOT NULL,
      CONCAT("job_title, "),
      ""),
  IF
    (education_phases IS NOT NULL,
      CONCAT("education_phases, "),
      ""),
  IF
    (working_patterns IS NOT NULL,
      CONCAT("working_patterns, "),
      ""),
  IF
    (newly_qualified_teacher IS NOT NULL,
      CONCAT("newly_qualified_teacher, "),
      ""),
  IF
    (minimum_salary IS NOT NULL,
      CONCAT("minimum_salary, "),
      "")
      ),", ") AS criteria #make a comma-separated list of the names of the criteria searched for in this search - important because we need to be able to analyse these in combination, not just separately
FROM (
  SELECT
    created_at AS datetime,
    data_total_count AS results_returned,
    TRIM(LOWER(data_subject)) AS subject,
    id AS id,
  IF
    (REGEXP_CONTAINS(data_location,"[0-9]"),
      "postcode",
      TRIM(LOWER(data_location))) AS location,
    #if the location searched for contains a number anywhere, replace it with 'postcode' to anonymise it and allow all postcode searches to be counted together later
    data_radius AS radius,
  IF
    (ARRAY_LENGTH(data_phases)=0,
      NULL,
      ARRAY_TO_STRING(ARRAY(
        SELECT
          x
        FROM
          UNNEST(data_phases) AS x
        ORDER BY
          x)," or ")) AS education_phases,
    #sort the array and then concatenate it into a list separated by 'or' to allow more straightforward reporting later
    TRIM(LOWER(data_job_title)) AS job_title,
  IF
    (ARRAY_LENGTH(data_working_patterns)=0
      AND data_working_pattern IS NULL,
      NULL,
      COALESCE(ARRAY_TO_STRING(ARRAY(
          SELECT
            x
          FROM
            UNNEST(data_working_patterns) AS x
          ORDER BY
            x)," or "),
        data_working_pattern)) AS working_patterns,
    #sort the array and then concatenate it into a list separated by 'or' to allow more straightforward reporting later; also use the old single-value working_pattern field if this has been completed to handle legacy search schema
    data_newly_qualified_teacher AS newly_qualified_teacher,
    data_minimum_salary AS minimum_salary
  FROM
    `teacher-vacancy-service.production_dataset.feb20_audit_data`
  WHERE
    category="search_event" #the audit table contains different types of events; this just picks out the search events (not vacancy status changes, new job alert subscriptions etc.)
    AND data_total_count IS NOT NULL #exclude some very old junk data
    )
