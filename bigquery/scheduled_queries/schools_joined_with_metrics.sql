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
    CAST(urn AS STRING) AS urn,
    COUNT(*) AS vacancies_published,
    #the total number of vacancies this school published over all time
    COUNTIF(publish_on > DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)) AS vacancies_published_in_the_last_year,
    COUNTIF(publish_on > DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)) AS vacancies_published_in_the_last_quarter,
    COUNTIF(vacancy.status="published"
      AND expires_on > CURRENT_DATE()) AS vacancies_currently_live,
    #count this as vacancies which have been published and have not yet expired
    MAX(publish_on) AS date_last_published
  FROM
    `teacher-vacancy-service.production_dataset.vacancies_published` AS vacancy
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS organisationvacancy
  ON
    vacancy.id=organisationvacancy.vacancy_id
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.school` AS school
  ON
    organisationvacancy.organisation_id=school.id
  GROUP BY
    urn)
SELECT
  id,
  name,
  school.urn,
  address AS address1,
  #rename this as this is actually the first line of the address
  locality,
  address3,
  town,
  county,
  postcode,
  full_address AS address,
  phase,
  url,
  minimum_age,
  maximum_age,
  school_type,
  region,
  date_created,
  date_updated,
  detailed_school_type,
  local_authority,
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
  establishment_type_group,
  education_phase,
  religious_character,
  religious_ethos,
  number_of_pupils,
  ARRAY_TO_STRING(ARRAY(SELECT DISTINCT name FROM `teacher-vacancy-service.production_dataset.schoolgroup` AS trust LEFT JOIN `teacher-vacancy-service.production_dataset.feb20_schoolgroupmembership` AS schoolgroupmembership ON trust.id=schoolgroupmembership.school_group_id WHERE trust.type = "Multi-academy trust" AND schoolgroupmembership.school_id=school.id AND trust.status != "Closed"),", ") AS trust_name,
  telephone_number,
  head_title,
  head_first_name,
  head_last_name,
  head AS head_name,
  head_job_title AS head_preferred_job_title,
  GOR,
  RSC_region,
  capacity,
  urban_rural,
  reason_opened AS reason_establishment_opened,
  reason_closed AS reason_establishment_closed,
  ofsted_rating,
  federation,
  status,
  diocese,
  date_opened,
  website AS school_website
FROM
  `teacher-vacancy-service.production_dataset.school` AS school
LEFT JOIN
  school_user_metrics
USING
  (urn)
LEFT JOIN
  school_approver_metrics
USING
  (urn)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.STATIC_schools_historic_pre201119` AS historic_signups
ON
  CAST(historic_signups.URN AS STRING)=school.urn
LEFT JOIN
  school_vacancy_metrics
ON
  school_vacancy_metrics.urn=school.urn
WHERE
  detailed_school_type_in_scope
  AND school.status != "Closed" #exclude closed schools, as this is a table of in scope schools. Assume schools with a null status are closed - as we didn't update the GIAS data for these when we started populating this as a JSON string in the database.
