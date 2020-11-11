SELECT
  id,
  CAST(created_at AS date) AS created_date,
  CAST(updated_at AS date) AS updated_date,
  active,
  CAST(unsubscribed_at AS date) AS unsubscribed_date,
IF
  (NOT active,
    DATETIME_DIFF(unsubscribed_at,
      created_at,
      DAY),
    NULL) AS days_active,
  recaptcha_score,
  FIRST_VALUE(id) OVER (PARTITION BY email ORDER BY created_at) AS email_address_id,
  #the ID of the first job alert with this email address - allows us to string job alerts with the same email address together without including the PII in this view
IF
  (recaptcha_score IS NULL
    OR recaptcha_score > 0.5,
    TRUE,
    FALSE) AS human,
  ARRAY_TO_STRING(ARRAY(   #extract all search criteria from the JSON, except radius and location_category (because they are just location searches) and jobs_sort (because this isn't a search criterion)
    SELECT
      *
    FROM
      UNNEST(REGEXP_EXTRACT_ALL(search_criteria, r'\"([a-z_]+)\":')) AS criteria #we have to use REGEXP_EXTRACT_ALL here rather than JSON_EXTRACT... because the latter only supports value rather than key extraction
    WHERE
      criteria NOT IN ("radius",
        "jobs_sort",
        "location_category")
    ORDER BY
      criteria ASC )," and ") AS search_criteria,
IF
  (REGEXP_CONTAINS(JSON_EXTRACT_SCALAR(search_criteria,
        '$.location'), r"[0-9]+"),
    #anonymise postcodes
    "postcode",
    TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
          '$.location'))," ")) AS location,
  JSON_EXTRACT_SCALAR(search_criteria,
    '$.radius') AS radius,
  ARRAY_TO_STRING( (
    SELECT
      ARRAY(
      SELECT
        JSON_EXTRACT_SCALAR(working_patterns_string,
          '$') AS pattern
      FROM
        UNNEST(JSON_EXTRACT_ARRAY(search_criteria,
            '$.working_patterns')) AS working_patterns_string
      ORDER BY
        pattern ASC))," or ") AS working_patterns,
  ARRAY_TO_STRING( (
    SELECT
      ARRAY(
      SELECT
        JSON_EXTRACT_SCALAR(job_roles_string,
          '$') AS pattern
      FROM
        UNNEST(JSON_EXTRACT_ARRAY(search_criteria,
            '$.job_roles')) AS job_roles_string
      ORDER BY
        pattern ASC))," or ") AS job_roles,
  JSON_EXTRACT_SCALAR(search_criteria,
    '$.newly_qualified_teacher') AS newly_qualified_teacher,
  ARRAY_TO_STRING( (
    SELECT
      ARRAY(
      SELECT
        JSON_EXTRACT_SCALAR(education_phases_string,
          '$') AS phase
      FROM
        UNNEST(JSON_EXTRACT_ARRAY(search_criteria,
            '$.phases')) AS education_phases_string
      ORDER BY
        phase ASC ))," or ") AS education_phases,
  TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
        '$.subject'))," ") AS subject,
  TRIM(LOWER(JSON_EXTRACT_SCALAR(search_criteria,
        '$.keyword'))," ") AS keyword,
  (
  SELECT
    COUNT(DISTINCT alertrun.id)
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_daily_users_from_cloudfront_logs` AS user
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_alertrun` AS alertrun
  ON
    user.utm_source=alertrun.id
  WHERE
    "vacancy" IN UNNEST(user.job_alert_destinations)
    AND alertrun.subscription_id=subscription.id
    AND alertrun.run_on >= '2020-10-28' ) AS number_of_alert_emails_clicked_on,
  (
  SELECT
    COUNT(DISTINCT alertrun.id)
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_daily_users_from_cloudfront_logs` AS user
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_alertrun` AS alertrun
  ON
    user.utm_source=alertrun.id
  WHERE
    "edit" IN UNNEST(user.job_alert_destinations)
    AND alertrun.subscription_id=subscription.id
    AND alertrun.run_on >= '2020-10-28' ) AS number_of_edit_clicks,
  (
  SELECT
    COUNT(DISTINCT alertrun.id)
  FROM
    `teacher-vacancy-service.production_dataset.feb20_alertrun` AS alertrun
  WHERE
    alertrun.subscription_id=subscription.id
    AND alertrun.run_on >= '2020-10-28' ) AS number_of_alert_emails_sent
FROM
  `teacher-vacancy-service.production_dataset.feb20_subscription` AS subscription
ORDER BY
  created_date DESC
