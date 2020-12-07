  # Transforms the latest versions of scraped vacancy NoSQL documents from Firestore in scraped_vacancies_raw_latest into SQL-queriable rows
  # Also matches vacancies to schools where possible to allow this to be joined to the schools table, and if this is possible matches vacancies to vacancies on Teaching Vacancies.
  # Data for newly discovered vacancies *only* is appended to the CALCULATED_scraped_vacancies table to avoid calculating things more than once.
WITH
  stop_words AS (
  SELECT
    *
  FROM
    UNNEST(['at','of','to','and','or','for','with','but','may','be','as','x','from','including','per','in']) ),
  TV_vacancy AS (
  SELECT
    id,
    job_title
  FROM
    `teacher-vacancy-service.production_dataset.feb20_vacancy`),
  school_group AS (
  SELECT
    id,
    uid,
    name,
    postcode,
    status,
    date_opened,
    date_closed
  FROM
    `teacher-vacancy-service.production_dataset.schoolgroup`),
  scraped_vacancy AS (
  SELECT
    *
  FROM (
    SELECT
      CAST(JSON_EXTRACT(DATA,
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
    AND location_address_country = "United Kingdom"
    AND scraped_url NOT IN (
    SELECT
      scraped_url
    FROM
      `teacher-vacancy-service.production_dataset.CALCULATED_scraped_vacancies`)
 ),
  vacancy_to_school_matches AS (
  SELECT
    DISTINCT scraped_vacancy.scraped_url,
    school.id AS school_id,
    school.urn AS school_urn,
    school.name AS school_name,
    school.status AS school_status,
    school.date_closed AS school_closedate,
    school.date_opened AS school_opendate,
    school.date_created AS school_createddate
  FROM
    scraped_vacancy
  INNER JOIN
    `teacher-vacancy-service.production_dataset.school` AS school
  ON
  IF
    ( scraped_vacancy.location_address_postcode=school.postcode
      AND LOWER(scraped_vacancy.hiring_organisation_name)=LOWER(school.name),
      TRUE,
      scraped_vacancy.location_address_postcode=school.postcode )
  WHERE
    #exclude matches with schools which were closed or had not yet been created in GIAS on the date when the vacancy was published (note - will exclude a match if a school published a vacancy during academisation - i.e. after the new academy had been created in GIAS but before the old school had officially closed - because in this case we can't work out whether recruitment was for the old or the new school
      (school.status != "Closed"
        OR school.date_closed > scraped_vacancy.publish_on)
      AND date_created <= scraped_vacancy.publish_on ),
    vacancy_to_schoolgroup_matches AS (
    SELECT
      DISTINCT scraped_vacancy.scraped_url,
      school_group.id AS school_group_id,
      school_group.uid AS school_group_uid,
      school_group.name AS school_group_name,
      school_group.status AS school_group_status,
      school_group.date_closed AS school_group_closedate,
      school_group.date_opened AS school_group_opendate,
    FROM
      scraped_vacancy
    INNER JOIN
      school_group
    ON
    IF
      ( scraped_vacancy.location_address_postcode=school_group.postcode
        AND LOWER(scraped_vacancy.hiring_organisation_name)=LOWER(school_group.name),
        TRUE,
        scraped_vacancy.location_address_postcode=school_group.postcode )
    WHERE
      #exclude matches with school groups which were closed or had not yet been opened on the date when the vacancy was published
      (school_group.status != "Closed"
        OR school_group.date_closed > scraped_vacancy.publish_on)
      AND school_group.date_opened <= scraped_vacancy.publish_on ),
    vacancies_joined_to_schools_and_groups AS (
    SELECT
      scraped_vacancy.*,
      vacancy_to_school_matches.school_id,
      vacancy_to_school_matches.school_urn,
      school.name AS school_name,
      vacancy_to_schoolgroup_matches.school_group_id,
      vacancy_to_schoolgroup_matches.school_group_uid,
      vacancy_to_schoolgroup_matches.school_group_name
    FROM
      scraped_vacancy
    LEFT JOIN
      vacancy_to_school_matches
    ON
      scraped_vacancy.scraped_url=vacancy_to_school_matches.scraped_url
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.school` AS school
    ON
      school_urn=school.urn
    LEFT JOIN
      vacancy_to_schoolgroup_matches
    ON
      scraped_vacancy.scraped_url=vacancy_to_schoolgroup_matches.scraped_url
    WHERE
      (scraped_vacancy.scraped_url IN ( # only include matches with only 1 possible school or which don't match any schools
        SELECT
          scraped_url AS scraped_url,
        FROM
          vacancy_to_school_matches
        GROUP BY
          scraped_url
        HAVING
          COUNT(*)=1 )
        OR vacancy_to_school_matches.school_urn IS NULL)
      AND (scraped_vacancy.scraped_url IN ( # only include matches with only 1 possible school group or which don't match any school groups
        SELECT
          scraped_url AS scraped_url,
        FROM
          vacancy_to_schoolgroup_matches
        GROUP BY
          scraped_url
        HAVING
          COUNT(*)=1 )
        OR vacancy_to_schoolgroup_matches.school_group_id IS NULL)
    ORDER BY
      scraped_url ASC ),
    vacancy_to_vacancy_matches AS (
    SELECT
      vacancies_joined_to_schools_and_groups.scraped_url,
      TV_vacancy.id AS vacancy_id
    FROM
      vacancies_joined_to_schools_and_groups
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.school` AS school
    ON
      vacancies_joined_to_schools_and_groups.school_urn=school.urn
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_organisationvacancy` AS TV_organisationvacancy
    ON
      school.id=TV_organisationvacancy.organisation_id
    LEFT JOIN
      `teacher-vacancy-service.production_dataset.feb20_vacancy` AS TV_vacancy
    ON
      TV_organisationvacancy.vacancy_id=TV_vacancy.id #only match vacancies to TV vacancies from the matched school in our database
      AND ( (
        SELECT
          SAFE_DIVIDE(COUNTIF(scraped_words IS NULL
              OR TV_words IS NULL),
            COUNTIF(scraped_words IS NOT NULL
              AND TV_words IS NOT NULL)) #number of words that are in one title but not in the other as a proportion of the number of words that are in both titles
        FROM (
          SELECT
            *
          FROM
            UNNEST(SPLIT(LOWER(REGEXP_REPLACE(TV_vacancy.job_title,r'[^a-zA-Z0-9]', '')),' ')) AS words
          WHERE
            words NOT IN (
            SELECT
              *
            FROM
              stop_words) #don't count these words when working out the proportion
            ) AS scraped_words
        FULL JOIN (
          SELECT
            *
          FROM
            UNNEST(SPLIT(LOWER(REGEXP_REPLACE(TV_vacancy.job_title,r'[^a-zA-Z0-9]', '')),' ')) AS words
          WHERE
            words NOT IN (
            SELECT
              *
            FROM
              stop_words) ) AS TV_words
        ON
          scraped_words=TV_words))<0.2 #allow only 1 in 5 words to be in one title but not in the other
      AND vacancies_joined_to_schools_and_groups.publish_on > DATE_SUB(TV_vacancy.publish_on, INTERVAL 14 DAY) #only match vacancies which were published within a fortnight of a vacancy in our database
      AND vacancies_joined_to_schools_and_groups.publish_on < DATE_ADD(TV_vacancy.publish_on, INTERVAL 14 DAY) )
  SELECT
    DISTINCT vacancies_joined_to_schools_and_groups.*,
    `teacher-vacancy-service.production_dataset.categorise_vacancy_job_title`(vacancies_joined_to_schools_and_groups.title) AS vacancy_category,
  IF
    (vacancies_joined_to_schools_and_groups.school_id IS NOT NULL,
      "school",
    IF
      (vacancies_joined_to_schools_and_groups.school_group_id IS NOT NULL,
        "school_group",
        NULL)) AS vacancy_source,
    vacancy_to_vacancy_matches.vacancy_id
  FROM
    vacancies_joined_to_schools_and_groups
  LEFT JOIN
    vacancy_to_vacancy_matches
  ON
    vacancies_joined_to_schools_and_groups.scraped_url=vacancy_to_vacancy_matches.scraped_url
  WHERE
    vacancies_joined_to_schools_and_groups.scraped_url IN ( # only include matches with only 1 possible school
    SELECT
      scraped_url AS scraped_url,
    FROM
      vacancy_to_vacancy_matches
    GROUP BY
      scraped_url
    HAVING
      COUNT(*)=1 )
    OR vacancy_id IS NULL
  ORDER BY
    scraped_url ASC
