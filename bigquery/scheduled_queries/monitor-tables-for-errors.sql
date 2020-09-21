SELECT
  table,
  creation_time,
  last_modified_time,
  row_count,
  size_bytes,
IF
  (table LIKE "scraped_vacancies%"
    AND (
    SELECT
      COUNTIF(CAST(timestamp AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
    FROM
      `teacher-vacancy-service.production_dataset.scraped_vacancies_raw_changelog`
    WHERE
      operation="CREATE")=0,
    "No new URLs to crawl obtained last night.",
  IF
    (table LIKE "scraped_vacancies%"
      AND ((
        SELECT
          COUNTIF(CAST(timestamp AS DATE) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
        FROM
          `teacher-vacancy-service.production_dataset.scraped_vacancies_raw_changelog`
        WHERE
          operation="UPDATE")=0),
      "No new vacancies crawled last night.",
    IF
      (table NOT LIKE "CALCULATED_working_patterns_by_month%"
        AND table NOT LIKE "scraped_vacancies%"
        AND updated_today IS FALSE,
        "Table not updated last night as expected",
      IF
        (table LIKE "CALCULATED_working_patterns_by_month%"
          AND updated_this_month IS FALSE,
          "Table not updated last month as expected",
        IF
          (table LIKE "%school"
            AND row_count <28000,
            #sets a minimum threshold for the number of schools that should be in the database - this should not change much unless we change the scope, so going below this threshold most likely means the dataset in BQ is incomplete
            "Table appears incomplete",
            #check whether there are at least this many schools in the schools table
          IF
            (table LIKE "%vacancy"
              AND row_count <29000,
              #sets a minimum threshold for the number of schools that should be in the database - this should not change much unless we change the scope, so going below this threshold most likely means the dataset in BQ is incomplete
              "Table appears incomplete",
              #check whether there are at least this many schools in the schools table
            IF
              (table = "dsi_users"
                AND row_count <25000,
                #sets a minimum threshold for the number of users that should be in the DSI database - this should not decrease, so going below this threshold most likely means the dataset in BQ is incomplete
                "Table appears incomplete",
                #check whether there are at least this many users in the dsi_users table
              IF
                (table = "dsi_approvers"
                  AND row_count <35000,
                  #sets a minimum threshold for the number of approvers that should be in the DSI database - this should not decrease, so going below this threshold most likely means the dataset in BQ is incomplete
                  "Table appears incomplete",
                  #check whether there are at least this many approvers in the dsi_approvers table
                IF
                  ((table ="dsi_users"
                      AND (
                      SELECT
                        MAX(update_datetime)
                      FROM
                        `teacher-vacancy-service.production_dataset.dsi_users` ) < TIMESTAMP_SUB(CURRENT_TIMESTAMP(),INTERVAL 3 DAY)) #check the last updated date for any user's data from DSI - produce error if more than three days old (i.e. if longer ago than the last working day)
                    OR (table LIKE "feb20_%"
                      AND (
                      SELECT
                        MAX(run_on)
                      FROM
                        `teacher-vacancy-service.production_dataset.feb20_alertrun` ) < DATE_SUB(CURRENT_DATE(),INTERVAL 3 DAY)),
                    "Latest date a row was updated in a frequently updated table from this source was at least 3 days ago",
                    "OK"))))))))) AS status
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
      AND TYPE != 2 #exclude views of tables, which aren't actually written to by any scheduled queries so don't need monitoring
      AND table_id NOT LIKE "STATIC%" #don't monitor tables that don't change
      AND table_id != 'CALCULATED_table_error_status' #don't monitor the table this query outputs to as we haven't written to it yet
      ))
ORDER BY
  status DESC,
  last_modified_time DESC
