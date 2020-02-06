WITH
  school_user_metrics AS ( #work out current user-related metric values for all individual schools for use in the main query later
  SELECT
    school_urn AS urn,
    MIN(approval_datetime) AS dsi_signup_date,
    #the earliest date that a user is recorded as authorised for TV access in DSI - for schools who signed up *after* we moved to DSI for authorisation in Nov 2019 this is the date the school first signed up
    COUNT(*) AS number_of_users #the current number of users this school has authorised to access TV in DSI
  FROM
    `teacher-vacancy-service.production_dataset.users` AS users
  GROUP BY
    school_urn ),
  school_vacancy_metrics AS ( #work out current vacancy-related metric values for all individual schools for use in the main query later
  SELECT
    school.urn AS urn,
    COUNT(*) AS vacancies_published,
    #the total number of vacancies this school published over all time
    COUNTIF(CAST(publish_on AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)) AS vacancies_published_in_the_last_year,
    COUNTIF(CAST(publish_on AS DATE) > DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)) AS vacancies_published_in_the_last_quarter,
    COUNTIF(status="published"
      AND CAST(expiry_time AS DATE) > CURRENT_DATE()) AS vacancies_currently_live #count this as vacancies which have been published and have not yet expired
  FROM
    `teacher-vacancy-service.production_dataset.vacancies` AS vacancies
  WHERE
    status != "trashed" #exclude deleted vacancies from the counts above
    AND status != "draft" #exclude vacancies which have not (yet) been published from the counts above
  GROUP BY
    vacancies.school.urn ),
  mat_metrics AS ( #make a table of academy trusts (MATs and SATs) with current values of trust related metrics for inclusion in main query later
  SELECT
    GIAS.Trusts__name_ AS trust_name,
    COUNT(*) AS trust_size #count the total number of academies in the trust according to the latest GIAS download
  FROM
    `teacher-vacancy-service.production_dataset.STATIC_GIAS_Feb20` AS GIAS
  GROUP BY
    GIAS.Trusts__name_ )
SELECT
  school.id,
  school.name,
  school.urn,
  school.address AS address1, #rename this as this is actually the first line of the address
  school.locality,
  school.address3,
  school.town,
  school.county,
  school.postcode,
  CONCAT(IFNULL(CONCAT(school.address,"\n"),
      ""),IFNULL(CONCAT(school.locality,"\n"),
      ""),IFNULL(CONCAT(school.address3,"\n"),
      ""),IFNULL(CONCAT(school.town,"\n"),
      ""),IFNULL(CONCAT(school.county,"\n"),
      ""),IFNULL(school.postcode,
      "")) AS address, #stick all the address components into a single string to save handling this in multiple dashboards further down the pipeline
  school.phase,
  school.url,
  school.minimum_age,
  school.maximum_age,
  school_type.label AS school_type, #extract school type from reference data table
  region.string_field_1 AS region, #extract region name from reference data table
  school.created_at,
  school.updated_at,
  detailed_school_type.label AS detailed_school_type, #extract detailed school type from reference data table
  school.local_authority,
IF
  (historic_signups.School_been_added IS TRUE,
    historic_signups.Date_first_signed_up,
    CAST(school_user_metrics.dsi_signup_date AS DATE)) AS signup_date, #In Nov 19 we switched to DSI for authorisation. Since then we can use DSI data to tell whether a school has signed up. If the school was signed up before then we have to use a historic data table. This uses the historic signup date if the school signed up pre-DSI authorisation, but uses the DSI date if it hadn't - and if it still hasn't passes on a null value.
IF
  (historic_signups.School_been_added IS TRUE,
    TRUE,
  IF
    (school_user_metrics.number_of_users >0,
      TRUE,
      FALSE)) AS signed_up, #similarly, if the school had signed up pre-DSI, sets signed_up to true; otherwise, work this out from the number of users the school has on DSI
  school_user_metrics.number_of_users AS number_of_users,
  IFNULL(school_vacancy_metrics.vacancies_published,
    0) AS vacancies_published, #convert null values for vacancies_published into zeros
  IFNULL(school_vacancy_metrics.vacancies_published_in_the_last_year,
    0) AS vacancies_published_in_the_last_year,
  IFNULL(school_vacancy_metrics.vacancies_published_in_the_last_quarter,
    0) AS vacancies_published_in_the_last_quarter,
  IFNULL(school_vacancy_metrics.vacancies_published_in_the_last_quarter,
    0) AS vacancies_currently_live,
  GIAS.EstablishmentTypeGroup__name_ AS establishment_type_group,
  GIAS.PhaseOfEducation__name_ AS education_phase,
  GIAS.ReligiousCharacter__name_ AS religious_character,
  GIAS.ReligiousEthos__name_ AS religious_ethos,
  GIAS.NumberOfPupils AS number_of_pupils,
  GIAS.Trusts__name_ AS trust_name,
  mat_metrics.trust_size AS academies_in_trust,
  GIAS.TelephoneNum AS telephone_number,
  GIAS.HeadFirstName AS head_first_name,
  GIAS.HeadLastName AS head_last_name,
  CONCAT(GIAS.HeadFirstName," ",GIAS.HeadLastName) AS head_name, #stick these together for easy use in mailing lists etc. further down the pipeline
  GIAS.GOR__name_ AS GOR,
  GIAS.RSCRegion__name_ AS RSC_region,
IF
  (GIAS.Trusts__name_ IS NULL,
    "Single school",
  IF
    (mat_metrics.trust_size=1,
      "SAT",
      "MAT")) AS tag #categorise the school as either a single school, part of a SAT or part of a MAT to provide a simplified dimension for analysis further down the pipeline
FROM
  `teacher-vacancy-service.production_dataset.school` AS school
LEFT JOIN
  `teacher-vacancy-service.production_dataset.school_type` AS school_type
ON
  school_type.id=school.school_type_id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.region` AS region
ON
  region.string_field_0=school.region_id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.detailed_school_type` AS detailed_school_type
ON
  detailed_school_type.id=school.detailed_school_type_id
LEFT JOIN
  school_user_metrics
ON
  school_user_metrics.urn=school.urn
LEFT JOIN
  `teacher-vacancy-service.production_dataset.STATIC_schools_historic_pre201119` AS historic_signups
ON
  historic_signups.URN=school.urn
LEFT JOIN
  school_vacancy_metrics
ON
  school_vacancy_metrics.urn=CAST(school.urn AS STRING)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.STATIC_GIAS_Feb20` AS GIAS
ON
  GIAS.URN=school.urn
LEFT JOIN
  mat_metrics
ON
  mat_metrics.trust_name=GIAS.Trusts__name_
WHERE
  detailed_school_type.code IN ( #exclude schools recorded in our database which have an out of scope establishment type
  SELECT
    code
  FROM
    `teacher-vacancy-service.production_dataset.STATIC_establishment_types_in_scope`)
  AND (GIAS.URN IS NOT NULL #ideally, we'd exclude schools that have status="closed" here, but we don't have this field in the nightly data from the database. So, we're assuming that the GIAS data download is limited to just schools in scope and excludes closed schools - and so excluding schools from the results if they're not in the GIAS download
    OR number_of_users > 0) #the exception to this is schools which we now know are in scope because DSI has allowed them to authorise users to use TV. Schools with users are included in these results even though they have not yet appeared in the GIAS data - this will happen over time as the data gets out of date and does not include some newly opened or academised schools. These schools will have null values for the fields that can only be obtained from GIAS.
