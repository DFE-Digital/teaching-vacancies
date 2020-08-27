SELECT
  id,
  name,
  CAST(created_at AS DATE) AS date_created,
  CAST(updated_at AS DATE) AS date_updated,
  data_closed_date AS date_closed,
  data_companies_house_number AS companies_house_number,
  REPLACE(data_group_county,"Not recorded",NULL) AS county,
  data_group_id AS group_id,
  data_group_locality AS locality,
  data_group_name AS group_name,
  data_group_postcode AS postcode,
  data_group_status AS status,
  data_group_status_code AS status_code,
  data_group_street AS street,
  data_group_town AS town,
  #put a full address together from its components so we only have to do this in one place
  CONCAT(IFNULL(CONCAT(name,"\n"),
      ""),IFNULL(CONCAT(data_group_street,"\n"),
      ""),IFNULL(CONCAT(data_group_locality,"\n"),
      ""),IFNULL(CONCAT(data_group_town,"\n"),
      ""),IFNULL(CONCAT(REPLACE(data_group_county,"Not recorded",NULL),"\n"),
      ""),IFNULL(data_group_postcode,
      "")) AS full_address,
  data_group_type AS type,
  data_group_type_code AS type_code,
  data_group_uid AS uid,
  data_head_of_group_first_name AS head_first_name,
  data_head_of_group_last_name AS head_last_name,
  REPLACE(data_head_of_group_title,"Not recorded",NULL) AS head_title,
  data_incorporated_on_open_date AS date_opened,
  data_ukprn AS ukprn
FROM
  `teacher-vacancy-service.production_dataset.feb20_organisation` AS organisation
WHERE
  type="SchoolGroup" #excludes Schools
