SELECT
  DISTINCT COALESCE(dsi_users_now.user_id,
    latest_timestamped_dsi_users.user_id) AS user_id,
  COALESCE(dsi_users_now.role,
    latest_timestamped_dsi_users.role) AS role,
IF
  (dsi_users_now.approval_datetime IS NOT NULL,
    CAST(dsi_users_now.approval_datetime AS DATE),
  IF
    (latest_timestamped_dsi_users.from_date IS NOT NULL,
      latest_timestamped_dsi_users.from_date,
      CURRENT_DATE())) AS from_date,
IF
  (dsi_users_now.user_id IS NULL
    AND latest_timestamped_dsi_users.to_date IS NULL,
    CURRENT_DATE(),
  IF
    (dsi_users_now.user_id IS NULL,
      latest_timestamped_dsi_users.to_date,
      NULL)) AS to_date,
  #if we find that a user from the previous table isn't in the current table, set the to_date to today's date (i.e. assume that the user left about now)
  COALESCE(CAST(dsi_users_now.update_datetime AS DATE),
    latest_timestamped_dsi_users.last_updated_date) AS last_updated_date,
  COALESCE(dsi_users_now.given_name,
    latest_timestamped_dsi_users.given_name) AS given_name,
  COALESCE(dsi_users_now.family_name,
    latest_timestamped_dsi_users.family_name) AS family_name,
  COALESCE(dsi_users_now.email,
    latest_timestamped_dsi_users.email) AS email,
  COALESCE(dsi_users_now.school_urn,
    latest_timestamped_dsi_users.school_urn) AS school_urn,
  COALESCE( dsi_users_now.organisation_uid,
    latest_timestamped_dsi_users.organisation_uid) AS organisation_uid
FROM
  `teacher-vacancy-service.production_dataset.dsi_users` AS dsi_users_now
FULL JOIN
  `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users` AS latest_timestamped_dsi_users
ON
  dsi_users_now.user_id=latest_timestamped_dsi_users.user_id
  AND (dsi_users_now.school_urn=latest_timestamped_dsi_users.school_urn
    OR COALESCE(dsi_users_now.school_urn,
      latest_timestamped_dsi_users.school_urn) IS NULL)
  AND (dsi_users_now.organisation_uid=latest_timestamped_dsi_users.organisation_uid
    OR COALESCE(dsi_users_now.organisation_uid,
      latest_timestamped_dsi_users.organisation_uid) IS NULL)
  AND CAST(dsi_users_now.approval_datetime AS DATE)=latest_timestamped_dsi_users.from_date
WHERE
  COALESCE(dsi_users_now.school_urn,
    latest_timestamped_dsi_users.school_urn,
    dsi_users_now.organisation_uid,
    latest_timestamped_dsi_users.organisation_uid ) IS NOT NULL
  AND
IF
  ((
    SELECT
      COUNT(*)
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users`
    WHERE
      to_date IS NULL
      AND user_id NOT IN (
      SELECT
        user_id
      FROM
        `teacher-vacancy-service.production_dataset.dsi_users` ) ) < 500,
    TRUE,
    ERROR("Error: 500+ users that were recorded as signed up yesterday don't appear to be today."))
ORDER BY
  user_id ASC
