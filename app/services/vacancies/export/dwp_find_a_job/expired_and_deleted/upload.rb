module Vacancies::Export::DwpFindAJob::ExpiredAndDeleted
  class Upload < Vacancies::Export::DwpFindAJob::UploadBase
    FILENAME_PREFIX = "TeachingVacancies-expire".freeze
    QUERY_CLASS = Query
    XML_CLASS = Xml
  end
end
