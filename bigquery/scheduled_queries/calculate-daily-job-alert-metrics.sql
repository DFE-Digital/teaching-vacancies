WITH
  dates AS ( #all dates up to yesterday that the output table doesn't already include
  SELECT
    date
  FROM
    UNNEST(GENERATE_DATE_ARRAY('2018-05-03', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), INTERVAL 1 DAY)) AS date
  WHERE
    date NOT IN (
    SELECT
      date
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_job_alert_metrics`)),
  job_alert_emails_sent AS (
  SELECT
    run_on AS date,
    COUNT(*) AS number_of_alert_emails_sent
  FROM
    `teacher-vacancy-service.production_dataset.feb20_alertrun` AS alertrun
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.job_alert` AS job_alert
  ON
    alertrun.subscription_id = job_alert.id
  WHERE
    human
  GROUP BY
    date ) (
  SELECT
    date,
    (
    SELECT
      COUNTIF(created_date=date)
    FROM
      `teacher-vacancy-service.production_dataset.job_alert`
    WHERE
      human IS NOT FALSE) AS job_alerts_created,
    (
    SELECT
      COUNTIF(updated_date=date)
    FROM
      `teacher-vacancy-service.production_dataset.job_alert`
    WHERE
      human IS NOT FALSE) AS job_alerts_updated,
    (
    SELECT
      COUNTIF(created_date<=date)
    FROM
      `teacher-vacancy-service.production_dataset.job_alert`
    WHERE
      human IS NOT FALSE ) AS job_alerts_live,
    (
    SELECT
      COUNT(DISTINCT
      IF
        (created_date<=date,
          email_address_id,
          NULL))
    FROM
      `teacher-vacancy-service.production_dataset.job_alert` AS job_alert
    WHERE
      human IS NOT FALSE ) AS emails_subscribed_to_job_alerts,
    #the number of unique emails that were subscribed to job alerts on this date
    job_alert_emails_sent.number_of_alert_emails_sent
  FROM
    dates
  LEFT JOIN
    job_alert_emails_sent
  USING
    (date))
UNION ALL (
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_job_alert_metrics`)
ORDER BY
  date DESC
