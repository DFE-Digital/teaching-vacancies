SELECT
  table,
  creation_time,
  last_modified_time,
  row_count,
  size_bytes,
IF
  (table NOT LIKE "CALCULATED_working_patterns_by_month%"
    AND updated_today IS FALSE,
    "Table not updated last night as expected",
  IF
    (table LIKE "CALCULATED_working_patterns_by_month%"
      AND updated_this_month IS FALSE,
      "Table not updated last month as expected",
    IF
      (table LIKE "%school"
        AND row_count <28000,
        "Table appears incomplete", #check whether there are at least this many schools in the schools table
      IF
        ((table ="users"
            AND (
            SELECT
              MAX(update_datetime)
            FROM
              `teacher-vacancy-service.production_dataset.users` ) < TIMESTAMP_SUB(CURRENT_TIMESTAMP(),INTERVAL 3 DAY)) #check the last updated date for any user's data from DSI - produce error if more than three days old (i.e. if longer ago than the last working day)
          OR (table LIKE "feb20_%"
            AND (
            SELECT
              MAX(updated_at)
            FROM
              `teacher-vacancy-service.production_dataset.feb20_audit_data` ) < TIMESTAMP_SUB(CURRENT_TIMESTAMP(),INTERVAL 3 DAY)) OR (table IN("alert_run","audit_data","detailed_school_type","general_feedback","leadership","pay_scale","region","school","school_type","subject","subscription","transaction_auditor","user","vacancy","vacancy_publish_feedback") #check the last entry in the audit log in the feb20_ tables from our database - error if this was more than 3 days ago
            AND (
            SELECT
              MAX(PARSE_DATETIME("%e %B %E4Y %R",string_field_3))
            FROM
              `teacher-vacancy-service.production_dataset.audit_data` ) < DATETIME_SUB(CURRENT_DATETIME(),INTERVAL 3 DAY)), #check the last entry in the audit log in the legacy tables from our database - error if this was more than 3 days ago
          "Latest date a row was updated in a frequently updated table from this source was at least 3 days ago",
          "OK")))) AS status
FROM (
  SELECT
    table,
    creation_time,
    last_modified_time,
    row_count,
    size_bytes,
  IF
    (CAST(last_modified_time AS DATE) = CURRENT_DATE(),
      TRUE,
      FALSE) AS updated_today,
  IF
    (CAST(last_modified_time AS DATE) >= DATE_TRUNC(CURRENT_DATE(),MONTH),
      TRUE,
      FALSE) AS updated_this_month
  FROM (
    SELECT
      table_id AS table,
      TIMESTAMP_MILLIS(creation_time) AS creation_time,
      TIMESTAMP_MILLIS(last_modified_time) AS last_modified_time,
      row_count,
      size_bytes
    FROM
      `teacher-vacancy-service.production_dataset.__TABLES__`
    WHERE
      TYPE != 3 #exclude tables which are just Google Sheets - these don't have meaningful time/size data in __TABLES__
      AND table_id NOT LIKE "STATIC%" #don't monitor tables that don't change
      ))
ORDER BY
  status DESC,
  last_modified_time DESC
