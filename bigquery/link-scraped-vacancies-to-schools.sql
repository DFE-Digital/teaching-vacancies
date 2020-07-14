  # Transforms the latest versions of scraped vacancy NoSQL documents from Firestore in scraped_vacancies_raw_latest into SQL-queriable rows
  # Also matches vacancies to schools where possible to allow this to be joined to the schools table.
WITH
  scraped_vacancy AS (
  SELECT
    *
  FROM (
    SELECT
      DISTINCT CAST(JSON_EXTRACT(DATA,
          '$.scraped') AS BOOL) AS scraped,
      JSON_EXTRACT_SCALAR(DATA,
        '$.url') AS scraped_url,
      CAST(JSON_EXTRACT(DATA,
          '$.expired_before_scrape') AS BOOL) AS expired_before_scrape,
      JSON_EXTRACT_SCALAR(DATA,
        '$.source') AS source,
      TIMESTAMP_MILLIS(CAST(JSON_EXTRACT(DATA,
            '$.timestampUrlFound') AS INT64)) AS timestamp_url_found,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.title') AS title,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.description') AS description,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.image[0]') AS image_url,
      JSON_EXTRACT_SCALAR(REPLACE(JSON_EXTRACT_SCALAR(DATA,
            '$.json'),"@type","type"),
        '$.hiringOrganization.type') AS hiring_organisation_type,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.hiringOrganization.name') AS hiring_organisation_name,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.hiringOrganization.sameAs') AS hiring_organisation_url,
      CAST(PARSE_TIMESTAMP("%FT%H:%M:%E*SZ",JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
              '$.json'),
            '$.datePosted')) AS DATE) AS publish_on,
      JSON_EXTRACT_SCALAR(REPLACE(JSON_EXTRACT_SCALAR(DATA,
            '$.json'),"@type","type"),
        '$.jobLocation.type') AS location_type,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.jobLocation.address.streetAddress') AS location_address_street,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.jobLocation.address.postalCode') AS location_address_postcode,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.jobLocation.address.addressLocality') AS location_address_locality,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.jobLocation.address.addressRegion') AS location_address_region,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.jobLocation.address.addressCountry') AS location_address_country,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.baseSalary.currency') AS salary_currency,
      JSON_EXTRACT(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.baseSalary.value.minValue') AS salary_min,
      JSON_EXTRACT(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.baseSalary.value.maxValue') AS salary_max,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.baseSalary.value.unitText') AS salary_unit,
      CAST(PARSE_TIMESTAMP("%FT%H:%M:%E*SZ",JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
              '$.json'),
            '$.validThrough')) AS DATE) AS expires_on,
      JSON_EXTRACT_SCALAR(JSON_EXTRACT_SCALAR(DATA,
          '$.json'),
        '$.employmentType') AS employment_type,
    FROM
      `teacher-vacancy-service.production_dataset.scraped_vacancies_raw_latest`)
  WHERE
    scraped
    AND NOT expired_before_scrape
    AND location_address_country = "United Kingdom"),
  vacancy_matches AS (
  SELECT
    DISTINCT scraped_vacancy.scraped_url,
    school.urn AS school_urn,
    school.name AS school_name,
    school.data_establishmentstatus_name AS school_status,
    school.data_closedate AS school_closedate,
    school.data_opendate AS school_opendate,
    school.created_at AS school_createddate
  FROM
    scraped_vacancy
  INNER JOIN
    `teacher-vacancy-service.production_dataset.feb20_school` AS school
  ON
  IF
    ( scraped_vacancy.location_address_postcode=school.postcode
      AND LOWER(scraped_vacancy.hiring_organisation_name)=LOWER(school.name),
      TRUE,
      scraped_vacancy.location_address_postcode=school.postcode )
  WHERE
    #exclude matches with schools which were closed or had not yet been created in GIAS on the date when the vacancy was published (note - will exclude a match if a school published a vacancy during academisation - i.e. after the new academy had been created in GIAS but before the old school had officially closed - because in this case we can't work out whether recruitment was for the old or the new school
      (school.data_establishmentstatus_name != "Closed"
        OR school.data_closedate > scraped_vacancy.publish_on)
      AND CAST(school.created_at AS DATE) <= scraped_vacancy.publish_on )
  SELECT
    scraped_vacancy.*,
    vacancy_matches.school_urn,
    school.name AS school_name
  FROM
    scraped_vacancy
  LEFT JOIN
    vacancy_matches
  ON
    scraped_vacancy.scraped_url=vacancy_matches.scraped_url
  LEFT JOIN
    `teacher-vacancy-service.production_dataset.feb20_school`AS school
  ON
    school_urn=school.urn
  WHERE
    scraped_vacancy.scraped_url IN ( # only include matches with only 1 possible school
    SELECT
      scraped_url AS scraped_url,
    FROM
      vacancy_matches
    GROUP BY
      scraped_url
    HAVING
      COUNT(*)=1 )
    OR vacancy_matches.school_urn IS NULL
  ORDER BY
    scraped_url ASC
