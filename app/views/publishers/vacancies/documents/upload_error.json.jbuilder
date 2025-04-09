json.error do
  json.message "#{@document.original_filename} #{vacancy.errors[:supporting_documents].first}"
end
json.partial! "file", document: @document
