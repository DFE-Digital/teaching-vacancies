SELECT
  date,
  slug,
  file_extension,
  document_name,
  MAX(unique_downloads) AS unique_downloads #if the latest unique_downloads of a particular document on a particular day in the Google Sheet from GA differs from the version we have in the table already, take the higher of the two values
FROM (
  SELECT
    Date AS date,
    SPLIT(TRIM(Page_path_level_2,"/"),"?")[ORDINAL(1)] AS slug,
    #remove the / from the front of the path and strip out any parameters after a ? to convert the level 2 path into the vacancy slug
    ARRAY_REVERSE(SPLIT(Event_Label,"."))[ORDINAL(1)] AS file_extension,
    #select everything after the *last* . as the file extension
    TRIM(REPLACE(Event_Label,ARRAY_REVERSE(SPLIT(Event_Label,"."))[ORDINAL(1)],""),".") AS document_name,
    #replace the file extension with a null string to extract the document name (this allows for period characters in the document name)
    Unique_Events AS unique_downloads
  FROM
    `teacher-vacancy-service.production_dataset.GA_documents_downloaded_each_day` AS latest_table
  WHERE
    Date IS NOT NULL
  UNION ALL
  SELECT
    date,
    slug,
    file_extension,
    document_name,
    unique_downloads
  FROM
    `teacher-vacancy-service.production_dataset.CALCULATED_documents_downloaded_each_day` AS previous_table )
GROUP BY
  date,
  slug,
  file_extension,
  document_name
