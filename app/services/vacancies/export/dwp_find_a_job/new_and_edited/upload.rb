module Vacancies::Export::DwpFindAJob::NewAndEdited
  class Upload < Vacancies::Export::DwpFindAJob::UploadBase
    FILENAME_PREFIX = "TeachingVacancies-upload".freeze
    QUERY_CLASS = Query
    XML_CLASS = Xml
  end
end
