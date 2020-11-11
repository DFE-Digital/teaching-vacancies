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
      `teacher-vacancy-service.production_dataset.CALCULATED_job_alert_metrics`)
    OR date >= CURRENT_DATE - 7),
  #recalculate the last 7 days' worth of data each night so that we pick up job alert email CTRs for up to a week after sending the email, but then fix this data
  job_alert_emails_sent AS (
  SELECT
    alertrun.run_on AS date,
    COUNT(DISTINCT alertrun.id) AS number_of_alert_emails_sent,
    COUNT(DISTINCT
    IF
      ("vacancy" IN UNNEST(users_from_job_alert_emails.job_alert_destinations),
        users_from_job_alert_emails.alertrun_id,
        NULL)) AS number_of_alert_emails_clicked_on,
    COUNT(DISTINCT
    IF
      ("unsubscribe" IN UNNEST(users_from_job_alert_emails.job_alert_destinations),
        users_from_job_alert_emails.alertrun_id,
        NULL)) AS number_of_alert_emails_unsubscribed_from,
    COUNT(DISTINCT
    IF
      ("edit" IN UNNEST(users_from_job_alert_emails.job_alert_destinations),
        users_from_job_alert_emails.alertrun_id,
        NULL)) AS number_of_alert_emails_edited
  FROM
    `teacher-vacancy-service.production_dataset.feb20_alertrun` AS alertrun
  LEFT JOIN (
    SELECT
      utm_source AS alertrun_id,
      job_alert_destinations
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_daily_users_from_cloudfront_logs`
    WHERE
      from_job_alert
      AND utm_source IS NOT NULL
      AND utm_source != "subscription") AS users_from_job_alert_emails
  ON
    alertrun.id = users_from_job_alert_emails.alertrun_id
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.job_alert` AS job_alert
  ON
    alertrun.subscription_id = job_alert.id
  WHERE
    human
  GROUP BY
    date
  ORDER BY
    date DESC) (
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
      COUNTIF(created_date<=date
        AND ((unsubscribed_date IS NULL
            AND active)
          OR unsubscribed_date>date))
    FROM
      `teacher-vacancy-service.production_dataset.job_alert`
    WHERE
      human IS NOT FALSE ) AS job_alerts_live,
    (
    SELECT
      COUNTIF(unsubscribed_date=date)
    FROM
      `teacher-vacancy-service.production_dataset.job_alert`
    WHERE
      human IS NOT FALSE ) AS job_alerts_unsubscribed,
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
    job_alert_emails_sent.number_of_alert_emails_sent,
    job_alert_emails_sent.number_of_alert_emails_clicked_on,
    job_alert_emails_sent.number_of_alert_emails_unsubscribed_from,
    job_alert_emails_sent.number_of_alert_emails_edited,
    SAFE_DIVIDE(job_alert_emails_sent.number_of_alert_emails_clicked_on,
      job_alert_emails_sent.number_of_alert_emails_sent) AS job_alert_email_vacancy_ctr,
    SAFE_DIVIDE(job_alert_emails_sent.number_of_alert_emails_unsubscribed_from,
      job_alert_emails_sent.number_of_alert_emails_sent) AS job_alert_email_unsubscribe_ctr,
    SAFE_DIVIDE(job_alert_emails_sent.number_of_alert_emails_edited,
      job_alert_emails_sent.number_of_alert_emails_sent) AS job_alert_email_edit_ctr
  FROM
    dates
  LEFT JOIN
    job_alert_emails_sent
  USING
    (date))
UNION ALL (
  SELECT
    date,
    job_alerts_created,
    job_alerts_updated,
    job_alerts_live,
    job_alerts_unsubscribed,
    emails_subscribed_to_job_alerts,
    number_of_alert_emails_sent,
    number_of_alert_emails_clicked_on,
    number_of_alert_emails_unsubscribed_from,
    number_of_alert_emails_edited,
    job_alert_email_vacancy_ctr,
    job_alert_email_unsubscribe_ctr,
    job_alert_email_edit_ctr
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_job_alert_metrics`
  WHERE
    date < CURRENT_DATE - 7)
ORDER BY
  date DESC
