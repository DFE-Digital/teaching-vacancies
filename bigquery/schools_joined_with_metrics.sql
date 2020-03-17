WITH
  school_user_metrics AS ( #work out current user-related metric values for all individual schools for use in the main query later
  SELECT
    CAST(school_urn AS STRING) AS urn,
    MIN(approval_datetime) AS dsi_signup_date,
    #the earliest date that a user is recorded as authorised for TV access in DSI - for schools who signed up *after* we moved to DSI for authorisation in Nov 2019 this is the date the school first signed up
    COUNT(*) AS number_of_users #the current number of users this school has authorised to access TV in DSI
  FROM
    `teacher-vacancy-service.production_dataset.dsi_users` AS users
  GROUP BY
    school_urn ),
  school_approver_metrics AS ( #work out current approver-related metric values for all individual schools for use in the main query later
  SELECT
    CAST(school_urn AS STRING) AS urn,
    COUNT(*) AS number_of_approvers #the current number of approvers this school has to authorise access to services in DSI
  FROM
    `teacher-vacancy-service.production_dataset.dsi_approvers` AS approvers
  GROUP BY
    school_urn ),
  school_vacancy_metrics AS ( #work out current vacancy-related metric values for all individual schools for use in the main query later
  SELECT
    CAST(school.urn AS STRING) AS urn,
    COUNT(*) AS vacancies_published,
    #the total number of vacancies this school published over all time
    COUNTIF(publish_on > DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)) AS vacancies_published_in_the_last_year,
    COUNTIF(publish_on > DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)) AS vacancies_published_in_the_last_quarter,
    COUNTIF(status="published"
      AND expires_on > CURRENT_DATE()) AS vacancies_currently_live,
    #count this as vacancies which have been published and have not yet expired
    MAX(publish_on) AS date_last_published
  FROM
    `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
  INNER JOIN
    `teacher-vacancy-service.production_dataset.feb20_school` AS school
  ON
    vacancy.school_id=school.id
  WHERE
    status != "trashed" #exclude deleted vacancies from the counts above
    AND status != "draft" #exclude vacancies which have not (yet) been published from the counts above
  GROUP BY
    school.urn),
  mat_metrics AS ( #make a table of academy trusts (MATs and SATs) with current values of trust related metrics for inclusion in main query later
  SELECT
    school.data_Trusts_name AS trust_name,
    COUNT(*) AS trust_size #count the total number of academies in the trust according to the latest GIAS download
  FROM
    `teacher-vacancy-service.production_dataset.feb20_school` AS school
  GROUP BY
    school.data_Trusts_name )
SELECT
  school.id,
  school.name,
  school.urn,
  school.address AS address1,
  #rename this as this is actually the first line of the address
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
      "")) AS address,
  #stick all the address components into a single string to save handling this in multiple dashboards further down the pipeline
  school.phase,
  school.url,
  school.minimum_age,
  school.maximum_age,
  school_type.label AS school_type,
  #extract school type from reference data table
  region.name AS region,
  #extract region name from reference data table
  school.created_at,
  school.updated_at,
  detailed_school_type.label AS detailed_school_type,
  #extract detailed school type from reference data table
  school.local_authority,
IF
  (historic_signups.School_been_added IS TRUE,
    historic_signups.Date_first_signed_up,
    CAST(school_user_metrics.dsi_signup_date AS DATE)) AS signup_date,
  #In Nov 19 we switched to DSI for authorisation. Since then we can use DSI data to tell whether a school has signed up. If the school was signed up before then we have to use a historic data table. This uses the historic signup date if the school signed up pre-DSI authorisation, but uses the DSI date if it hadn't - and if it still hasn't passes on a null value.
IF
  (historic_signups.School_been_added IS TRUE,
    TRUE,
  IF
    (school_user_metrics.number_of_users >0,
      TRUE,
      FALSE)) AS signed_up,
  #similarly, if the school had signed up pre-DSI, sets signed_up to true; otherwise, work this out from the number of users the school has on DSI
  school_user_metrics.number_of_users AS number_of_users,
  school_approver_metrics.number_of_approvers AS number_of_approvers,
  IFNULL(school_vacancy_metrics.vacancies_published,
    0) AS vacancies_published,
  #convert null values for vacancies_published into zeros
  IFNULL(school_vacancy_metrics.vacancies_published_in_the_last_year,
    0) AS vacancies_published_in_the_last_year,
  IFNULL(school_vacancy_metrics.vacancies_published_in_the_last_quarter,
    0) AS vacancies_published_in_the_last_quarter,
  IFNULL(school_vacancy_metrics.vacancies_published_in_the_last_quarter,
    0) AS vacancies_currently_live,
  school_vacancy_metrics.date_last_published AS date_last_published,
  school.data_EstablishmentTypeGroup_name AS establishment_type_group,
  school.data_PhaseOfEducation_name AS education_phase,
  school.data_ReligiousCharacter_name AS religious_character,
  school.data_ReligiousEthos_name AS religious_ethos,
  school.data_NumberOfPupils AS number_of_pupils,
  school.data_Trusts_name AS trust_name,
  mat_metrics.trust_size AS academies_in_trust,
  school.data_TelephoneNum AS telephone_number,
  school.data_HeadTitle_name AS head_title,
  school.data_HeadFirstName AS head_first_name,
  school.data_HeadLastName AS head_last_name,
  CONCAT(school.data_HeadTitle_name," ",school.data_HeadFirstName," ",school.data_HeadLastName) AS head_name,
  #stick these together for easy use in mailing lists etc. further down the pipeline
  school.data_HeadPreferredJobTitle AS head_preferred_job_title,
  school.data_GOR_name AS GOR,
  school.data_RSCRegion_name AS RSC_region,
  school.data_SchoolCapacity AS capacity,
  school.data_UrbanRural_name AS urban_rural,
  school.data_ReasonEstablishmentOpened_name AS reason_establishment_opened,
  school.data_ReasonEstablishmentClosed_name AS reason_establishment_closed,
  school.data_OfstedRating_name AS ofsted_rating,
  school.data_LastChangedDate AS last_changed_date,
  school.data_Federations_name AS federation,
  school.data_EstablishmentStatus_name AS status,
  school.data_Diocese_name AS diocese,
  school.data_OpenDate AS date_opened,
  school.data_SchoolWebsite AS school_website,
IF
  (school.data_Trusts_name IS NULL,
    "Single school",
  IF
    (mat_metrics.trust_size=1,
      "SAT",
      "MAT")) AS tag #categorise the school as either a single school, part of a SAT or part of a MAT to provide a simplified dimension for analysis further down the pipeline
FROM
  `teacher-vacancy-service.production_dataset.feb20_school` AS school
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_school_type` AS school_type
ON
  school_type.id=school.school_type_id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_region` AS region
ON
  region.id=school.region_id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_detailed_school_type` AS detailed_school_type
ON
  detailed_school_type.id=school.detailed_school_type_id
LEFT JOIN
  school_user_metrics
ON
  school_user_metrics.urn=school.urn
LEFT JOIN
  school_approver_metrics
ON
  school_approver_metrics.urn=school.urn
LEFT JOIN
  `teacher-vacancy-service.production_dataset.STATIC_schools_historic_pre201119` AS historic_signups
ON
  CAST(historic_signups.URN AS STRING)=school.urn
LEFT JOIN
  school_vacancy_metrics
ON
  school_vacancy_metrics.urn=school.urn
LEFT JOIN
  mat_metrics
ON
  mat_metrics.trust_name=school.data_Trusts_name
WHERE
  detailed_school_type.code IN ( #exclude schools recorded in our database which have an out of scope establishment type
  SELECT
    code
  FROM
    `teacher-vacancy-service.production_dataset.STATIC_establishment_types_in_scope`)
  AND school.data_EstablishmentStatus_name IS NOT NULL
  AND school.data_EstablishmentStatus_name != "Closed" #exclude closed schools, as this is a table of in scope schools. Assume schools with a null status are closed - as we didn't update the GIAS data for these when we started populating this as a JSON string in the database.
