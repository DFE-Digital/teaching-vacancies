json.success do
  json.messageHtml t("jobs.file_upload_success_message", filename: @document.original_filename)
  json.messageText t("jobs.file_upload_success_message", filename: @document.original_filename)
end
json.partial! "file", document: @document
