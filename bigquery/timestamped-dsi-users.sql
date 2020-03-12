SELECT
  COALESCE(current_table.user_id,
    previous_table.user_id) AS user_id,
  COALESCE(current_table.role,
    previous_table.role) AS role,
  COALESCE(CAST(current_table.approval_datetime AS DATE),previous_table.from_date) AS from_date,
IF
  (current_table.user_id IS NULL
    AND previous_table.to_date IS NULL,
    CURRENT_DATE(),
    previous_table.to_date) AS to_date,
  #if we find that a user from the previous table isn't in the current table, set the to_date to today's date (i.e. assume that the user left about now)
  COALESCE(CAST(current_table.update_datetime AS DATE),
    previous_table.last_updated_date) AS last_updated_date,
  COALESCE(current_table.given_name,
    previous_table.given_name) AS given_name,
  COALESCE(current_table.family_name,
    previous_table.family_name) AS family_name,
  COALESCE(current_table.email,
    previous_table.email) AS email,
  current_table.school_urn
FROM
  `teacher-vacancy-service.production_dataset.dsi_users` AS current_table
FULL JOIN
  `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users` AS previous_table
ON
  current_table.user_id=previous_table.user_id
  AND current_table.school_urn=previous_table.school_urn
  AND CAST(current_table.approval_datetime AS DATE)=previous_table.from_date
WHERE
IF
  ((
    SELECT
      COUNT(*)
    FROM
      `teacher-vacancy-service.production_dataset.dsi_users`
    WHERE
      user_id NOT IN (
      SELECT
        user_id
      FROM
        `teacher-vacancy-service.production_dataset.CALCULATED_timestamped_dsi_users`
      WHERE
        to_date IS NULL) ) < 500,
    TRUE,
    ERROR("Error: Today's user table appears to have  than the previous version."))
