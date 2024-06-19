require "net/sftp"

module Vacancies::Export::DwpFindAJob
  # Base class for uploading vacancies to DWP Find a Job service.
  # Subclasses must define the following constants:
  # - FILENAME_PREFIX: the prefix for the filename of the XML file to be uploaded
  # - QUERY_CLASS: the class to use to query the vacancies to be uploaded
  # - XML_CLASS: the class to use to generate the XML from the vacancies
  class UploadBase
    attr_reader :from_date

    def initialize(from_date)
      @from_date = from_date
    end

    def call
      vacancies = self.class::QUERY_CLASS.new(from_date).vacancies
      xml = self.class::XML_CLASS.new(vacancies).xml
      file = Tempfile.new(filename)
      begin
        file.write(xml)
        file.flush # Ensure all data is written to disk before uploading
        upload_to_find_a_job_sftp(file.path)
      ensure
        file.close!
      end
      log_upload(vacancies.size)
    end

    private

    def upload_to_find_a_job_sftp(file_path)
      Net::SFTP.start(ENV.fetch("FIND_A_JOB_FTP_HOST", ""),
                      ENV.fetch("FIND_A_JOB_FTP_USER", ""),
                      password: ENV.fetch("FIND_A_JOB_FTP_PASSWORD", ""),
                      port: ENV.fetch("FIND_A_JOB_FTP_PORT", "")) do |sftp|
        sftp.upload!(file_path, "Inbound/#{filename}.xml")
      end
    end

    def filename
      @filename ||= "#{self.class::FILENAME_PREFIX}-#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
    end

    def log_upload(vacancies_number)
      Rails.logger.info("[DWP Find a Job] Uploaded '#{filename}.xml': Containing #{vacancies_number} vacancies.")
    end
  end
end
