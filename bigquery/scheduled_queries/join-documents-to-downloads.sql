SELECT
  document_downloads.slug,
  document_downloads.file_extension,
  document_downloads.document_name,
  SUM(document_downloads.unique_downloads) AS total_downloads,
  document.id,
  document.size,
  document.content_type,
  document.download_url,
  document.google_drive_id,
  CAST(document.created_at AS DATE) AS created_date,
  CAST(document.updated_at AS DATE) AS updated_date,
  document.vacancy_id
FROM
  `teacher-vacancy-service.production_dataset.CALCULATED_documents_downloaded_each_day` AS document_downloads
LEFT JOIN
  `teacher-vacancy-service.production_dataset.feb20_vacancy` AS vacancy
USING
  (slug)
RIGHT JOIN
  `teacher-vacancy-service.production_dataset.feb20_document` AS document
ON
  vacancy.id=document.vacancy_id
  AND CONCAT(document_downloads.document_name,".",document_downloads.file_extension)=document.name
GROUP BY
  document_downloads.slug,
  document_downloads.file_extension,
  document_downloads.document_name,
  document.id,
  document.size,
  document.content_type,
  document.download_url,
  document.google_drive_id,
  document.created_at,
  document.updated_at,
  document.vacancy_id
