CREATE TEMP FUNCTION
  convertFilenameToWords(filename STRING) AS (ARRAY_CONCAT(REGEXP_EXTRACT_ALL(REPLACE(LOWER(SPLIT(filename,".")[ORDINAL(1)]),"_"," "), r'([[:alpha:]]+)')));
WITH
  phrases_in_document_names AS (
  SELECT
    name,
    ARRAY(
    SELECT
      word
    FROM (
      SELECT
        #selects all words and phrases up to 5 words long that occur within the document name - contains a lot of repetition so could do with a refactor at some point / to include longer phrases too!
        word
      FROM (
        SELECT
          word,
          word_position
        FROM
          UNNEST(convertFilenameToWords(name)) AS word
        WITH
        OFFSET
          AS word_position ) AS words
      UNION ALL
      SELECT
        CONCAT(word," ",word2) AS word
      FROM (
        SELECT
          word,
          word_position
        FROM
          UNNEST(convertFilenameToWords(name)) AS word
        WITH
        OFFSET
          AS word_position ) AS words
      INNER JOIN (
        SELECT
          word2,
          word_position2
        FROM
          UNNEST(convertFilenameToWords(name)) AS word2
        WITH
        OFFSET
          AS word_position2 ) AS words2
      ON
        (words2.word_position2=words.word_position + 1)
      UNION ALL
      SELECT
        CONCAT(word," ",word2," ",word3) AS word
      FROM (
        SELECT
          word,
          word_position
        FROM
          UNNEST(convertFilenameToWords(name)) AS word
        WITH
        OFFSET
          AS word_position ) AS words
      INNER JOIN (
        SELECT
          word2,
          word_position2
        FROM
          UNNEST(convertFilenameToWords(name)) AS word2
        WITH
        OFFSET
          AS word_position2 ) AS words2
      ON
        (words2.word_position2=words.word_position + 1)
      INNER JOIN (
        SELECT
          word3,
          word_position3
        FROM
          UNNEST(convertFilenameToWords(name)) AS word3
        WITH
        OFFSET
          AS word_position3 ) AS words3
      ON
        (words3.word_position3=words.word_position + 2)
      UNION ALL
      SELECT
        CONCAT(word," ",word2," ",word3," ",word4) AS word
      FROM (
        SELECT
          word,
          word_position
        FROM
          UNNEST(convertFilenameToWords(name)) AS word
        WITH
        OFFSET
          AS word_position ) AS words
      INNER JOIN (
        SELECT
          word2,
          word_position2
        FROM
          UNNEST(convertFilenameToWords(name)) AS word2
        WITH
        OFFSET
          AS word_position2 ) AS words2
      ON
        (words2.word_position2=words.word_position + 1)
      INNER JOIN (
        SELECT
          word3,
          word_position3
        FROM
          UNNEST(convertFilenameToWords(name)) AS word3
        WITH
        OFFSET
          AS word_position3 ) AS words3
      ON
        (words3.word_position3=words.word_position + 2)
      INNER JOIN (
        SELECT
          word4,
          word_position4
        FROM
          UNNEST(convertFilenameToWords(name)) AS word4
        WITH
        OFFSET
          AS word_position4 ) AS words4
      ON
        (words4.word_position4=words.word_position + 3)
      UNION ALL
      SELECT
        CONCAT(word," ",word2," ",word3," ",word4," ",word5) AS word
      FROM (
        SELECT
          word,
          word_position
        FROM
          UNNEST(convertFilenameToWords(name)) AS word
        WITH
        OFFSET
          AS word_position ) AS words
      INNER JOIN (
        SELECT
          word2,
          word_position2
        FROM
          UNNEST(convertFilenameToWords(name)) AS word2
        WITH
        OFFSET
          AS word_position2 ) AS words2
      ON
        (words2.word_position2=words.word_position + 1)
      INNER JOIN (
        SELECT
          word3,
          word_position3
        FROM
          UNNEST(convertFilenameToWords(name)) AS word3
        WITH
        OFFSET
          AS word_position3 ) AS words3
      ON
        (words3.word_position3=words.word_position + 2)
      INNER JOIN (
        SELECT
          word4,
          word_position4
        FROM
          UNNEST(convertFilenameToWords(name)) AS word4
        WITH
        OFFSET
          AS word_position4 ) AS words4
      ON
        (words4.word_position4=words.word_position + 3)
      INNER JOIN (
        SELECT
          word5,
          word_position5
        FROM
          UNNEST(convertFilenameToWords(name)) AS word5
        WITH
        OFFSET
          AS word_position5 ) AS words5
      ON
        (words5.word_position5=words.word_position + 4) ) AS phrase
    WHERE
      NOT REGEXP_CONTAINS(word,"(jan)|(feb)|(mar)|(apr)|(may)|(jun)|(jul)|(aug)|(sept)|(oct)|(nov)|(dec)") #removes all phrases that include months (shorter phrases that occur either side of the month will still be included)
      AND NOT REGEXP_CONTAINS(word,"(^of)|(of$)|(^to)|(to$)|(^for)|(for$)|(^and)|(and$)") #removes phrases that begin or end with words that are only normally found in the middle of a phrase
      ) AS word
  FROM
    `teacher-vacancy-service.production_dataset.feb20_document` AS document )
SELECT
  "phrase" AS tag_type,
  phrase AS tag,
  download.date AS date,
  SUM(download.unique_downloads) AS downloads,
  COUNTIF(CAST(document.created_at AS DATE) = download.date) AS uploads,
  SUM(views.unique_views) AS vacancy_views
FROM
  phrases_in_document_names
CROSS JOIN
  UNNEST(phrases_in_document_names.word) AS phrase
RIGHT JOIN
  `teacher-vacancy-service.production_dataset.feb20_document` AS document
USING
  (name)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
ON
  document.vacancy_id=vacancy.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.CALCULATED_documents_downloaded_each_day` AS download
ON
  vacancy.slug=download.slug
  AND document.name=CONCAT(download.document_name,".",download.file_extension)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.CALCULATED_vacancies_viewed_each_day` AS views
ON
 download.slug=views.slug
 AND views.date=download.date
GROUP BY
  tag,
  date
UNION ALL
SELECT
  "content_type" AS tag_type,
  document.content_type AS tag,
  download.date AS date,
  SUM(download.unique_downloads) AS downloads,
  COUNTIF(CAST(document.created_at AS DATE) = download.date) AS uploads,
  SUM(views.unique_views) AS vacancy_views
FROM
  `teacher-vacancy-service.production_dataset.feb20_document` AS document
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
ON
  document.vacancy_id=vacancy.id
LEFT JOIN
  `teacher-vacancy-service.production_dataset.CALCULATED_documents_downloaded_each_day` AS download
ON
  vacancy.slug=download.slug
  AND document.name=CONCAT(download.document_name,".",download.file_extension)
LEFT JOIN
  `teacher-vacancy-service.production_dataset.CALCULATED_vacancies_viewed_each_day` AS views
ON
 download.slug=views.slug
 AND views.date=download.date
GROUP BY
  tag,
  date
ORDER BY
  date DESC,
  downloads DESC
