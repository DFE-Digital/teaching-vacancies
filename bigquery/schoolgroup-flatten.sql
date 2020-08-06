SELECT
  *,
IF
  (date_opened IS NULL
    OR date_incorporated IS NULL,
    COALESCE(date_opened,
      date_incorporated),
    LEAST(date_opened,date_incorporated)) AS earliest_date_opened
FROM (
  SELECT
    id,
    uid,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group ID') AS group_id,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Name') AS name,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Companies House Number') AS companies_house_number,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Type') AS type,
    SAFE.PARSE_DATE("%d/%m/%Y",
      JSON_EXTRACT_SCALAR(gias_data,
        '$.Closed Date')) AS date_closed,
    SAFE.PARSE_DATE("%d/%m/%Y",
      JSON_EXTRACT_SCALAR(gias_data,
        '$.Open Date')) AS date_opened,
    SAFE.PARSE_DATE("%d/%m/%Y",
      JSON_EXTRACT_SCALAR(gias_data,
        '$.Incorporated on')) AS date_incorporated,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Status') AS status,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Street') AS street,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Locality') AS locality,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Address 3') AS address3,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Town') AS town,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group County') AS county,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Group Postcode') AS postcode,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Head of Group Title') AS head_title,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Head of Group First Name') AS head_first_name,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.Head of Group Last Name') AS head_last_name,
    JSON_EXTRACT_SCALAR(gias_data,
      '$.UKPRN') AS UKPRN,
    REPLACE(gias_data,"=>",":")
  FROM (
    SELECT
      id,
      uid,
      REPLACE(REPLACE(REPLACE(gias_data,"=>",":"),"Not recorded","")," (open date)","") AS gias_data
    FROM
      `teacher-vacancy-service.production_dataset.feb20_schoolgroup`))
