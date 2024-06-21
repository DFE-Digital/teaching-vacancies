module Vacancies::Export::DwpFindAJob
  class Upload
    attr_reader :xml, :filename

    def initialize(xml:, filename:)
      @xml = xml
      @filename = filename
    end

    def call
      file = Tempfile.new(filename)
      begin
        file.write(xml)
        file.flush # Ensure all data is written to disk before uploading
        upload_to_find_a_job_sftp(file.path)
      ensure
        file.close!
      end
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
  end
end
