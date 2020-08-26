WITH
  trust AS ( #make a table of academy trusts (MATs and SATs) for inclusion in main query later
  SELECT
    school.data_Trusts_name AS name,
    COUNT(*) AS size #count the total number of academies in the trust
  FROM
    `teacher-vacancy-service.production_dataset.feb20_organisation` AS school
  WHERE
    type="School"
  GROUP BY
    school.data_Trusts_name )
SELECT
  organisation.id AS id,
  organisation.name AS name,
  urn,
  phase,
  url,
  minimum_age,
  maximum_age,
  address,
  town,
  county,
  postcode,
  local_authority,
  locality,
  address3,
  #put a full address together from its components so we only have to do this in one place
  CONCAT(IFNULL(CONCAT(address,"\n"),
      ""),IFNULL(CONCAT(locality,"\n"),
      ""),IFNULL(CONCAT(address3,"\n"),
      ""),IFNULL(CONCAT(town,"\n"),
      ""),IFNULL(CONCAT(county,"\n"),
      ""),IFNULL(postcode,
      "")) AS full_address,
  easting,
  northing,
  #flatten out these three reference data ID fields so we can also access their labels and codes
  school_type_id,
  schooltype.label AS school_type,
  schooltype.code AS school_type_code,
  region_id,
  region.name AS region,
  region.code AS region_code,
  detailed_school_type_id,
  detailedschooltype.code AS detailed_school_type_code,
  detailedschooltype.label AS detailed_school_type,
  #work out whether each school has an in scope type and record this so we only have to do this in one place
  CAST(detailedschooltype.code AS NUMERIC) IN (
  SELECT
    code
  FROM
    `teacher-vacancy-service.production_dataset.STATIC_establishment_types_in_scope`) AS detailed_school_type_in_scope,
  created_at AS date_created,
  updated_at AS date_updated,
  geolocation_x,
  geolocation_y,
  ST_GEOGPOINT(geolocation_x,
    geolocation_y) AS geolocation,
IF
  (data_Trusts_name IS NULL,
    "Single school",
  IF
    (trust.size=1,
      "SAT",
      "MAT")) AS tag,
  #categorise the school as either a single school, part of a SAT or part of a MAT to provide a simplified dimension for analysis further down the pipeline
  data_administrativeward_name AS administrative_ward,
  data_admissionspolicy_name AS admissions_policy,
  data_bsoinspectoratename_name AS bso_inspectorate_name,
  data_boarders_name AS boarders,
  data_boardingestablishment_name AS boarding_establishment,
  data_ccf_name AS ccf,
  data_censusareastatisticward_name AS census_area_statistic_ward,
  data_censusdate AS census_date,
  data_closedate AS date_closed,
  data_country_name AS country,
  data_dateoflastinspectionvisit AS date_last_inspected,
  data_diocese_name AS diocese,
  data_districtadministrative_name AS administrative_district,
  data_ebd_name AS ebd,
  data_edbyother_name AS ed_by_other,
  data_establishmentstatus_name AS status,
  data_establishmenttypegroup_name AS establishment_type_group,
  data_feheidentifier AS fe_he_identifier,
  data_ftprov_name AS ft_provider,
  data_federations_name AS federation,
  data_furthereducationtype_name AS fe_type,
  data_gor_name AS gor,
  data_gsslacode_name AS gssla_code,
  data_gender_name AS gender,
  data_headfirstname AS head_first_name,
  data_headlastname AS head_last_name,
  data_headpreferredjobtitle AS head_job_title,
  data_headtitle_name AS head_title,
  REPLACE(TRIM(data_headtitle_name || " " || data_headfirstname || " " || data_headlastname),"  "," ") AS head,
  data_inspectoratename_name AS inspectorate,
  data_inspectoratereport AS inspectorate_report,
  data_lsoa_name AS lsoa,
  data_lastchangeddate AS date_last_changed,
  data_msoa_name AS msoa,
  data_nextinspectionvisit AS next_inspection_visit,
  data_numberofboys AS number_of_boys,
  data_numberofgirls AS number_of_girls,
  data_numberofpupils AS number_of_pupils,
  data_nurseryprovision_name AS nursery_provision,
  data_officialsixthform_name AS official_sixth_form,
  data_ofstedlastinsp AS ofsted_last_insp,
  data_ofstedrating_name AS ofsted_rating,
  data_ofstedspecialmeasures_name AS ofsted_special_measures,
  data_opendate AS date_opened,
  data_parliamentaryconstituency_name AS parliamentary_constituency,
  data_percentagefsm AS percentage_fsm,
  data_phaseofeducation_name AS education_phase,
  data_placespru AS places_pru,
  data_previousestablishmentnumber AS previous_establishment_number,
  data_previousla_name AS previous_la,
  data_propsname AS props_name,
  data_rscregion_name AS rsc_region,
  data_reasonestablishmentclosed_name AS reason_closed,
  data_reasonestablishmentopened_name AS reason_opened,
  data_religiouscharacter_name AS religious_character,
  data_religiousethos_name AS religious_ethos,
  data_resourcedprovisioncapacity AS resourced_provision_capacity,
  data_resourcedprovisiononroll AS resourced_provision_on_roll,
  data_schoolcapacity AS capacity,
  data_schoolsponsorflag_name AS sponsor_flag,
  data_schoolsponsors_name AS sponsors,
  data_schoolwebsite AS website,
  data_sitename AS site,
  data_specialclasses_name AS special_classes,
  data_statutoryhighage AS statutory_high_age,
  data_statutorylowage AS statutory_low_age,
  data_teenmoth_name AS teenage_mothers,
  data_teenmothplaces AS teenage_mothers_places,
  data_telephonenum AS telephone_number,
  data_trustschoolflag_name AS trusts_school_flag,
  data_trusts_name AS trust,
  trust.size AS trust_size,
  data_typeofestablishment_name AS type_of_establishment,
  data_typeofresourcedprovision_name AS type_of_resourced_provision,
  data_ukprn AS ukprn,
  data_uprn AS uprn,
  data_urbanrural_name AS urban_rural
FROM
  `teacher-vacancy-service.production_dataset.feb20_organisation` AS organisation
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_schooltype` AS schooltype
ON
  organisation.school_type_id=schooltype.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_region` AS region
ON
  organisation.region_id=region.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_detailedschooltype` AS detailedschooltype
ON
  organisation.detailed_school_type_id=detailedschooltype.id
LEFT JOIN
  trust
ON
  data_trusts_name=trust.name
WHERE
  type="School" #excludes organisations which aren't schools, like School Groups i.e. MATs
