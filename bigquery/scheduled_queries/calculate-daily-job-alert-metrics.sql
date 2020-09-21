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
  job_alert AS ( #preprocess this table a bit before the main query
  SELECT
    id,
    email,
    expires_on,
    CAST(created_at AS DATE) AS created_on,
    CAST(updated_at AS DATE) AS updated_on,
    recaptcha_score,
  IF
    (recaptcha_score IS NULL,
      NULL,
      recaptcha_score>0.5) AS human #the job alert was likely to be created by a human if the Recaptcha score was over 50%
  FROM
    `teacher-vacancy-service.production_dataset.feb20_subscription` ) (
  SELECT
    date,
    (
    SELECT
      COUNTIF(created_on=date)
    FROM
      job_alert
    WHERE
      human IS NOT FALSE) AS job_alerts_created,
    (
    SELECT
      COUNTIF(updated_on=date)
    FROM
      job_alert
    WHERE
      human IS NOT FALSE) AS job_alerts_updated,
    (
    SELECT
      COUNTIF(created_on<=date)
    FROM
      job_alert
    WHERE
      human IS NOT FALSE ) AS job_alerts_live,
    (
    SELECT
      COUNT(DISTINCT
      IF
        (created_on<=date,
          email,
          NULL))
    FROM
      job_alert
    WHERE
      human IS NOT FALSE ) AS emails_subscribed_to_job_alerts #the number of unique emails that were subscribed to job alerts on this date
  FROM
    dates)
UNION ALL (
  SELECT
    *
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_job_alert_metrics`)
ORDER BY
  date DESC
