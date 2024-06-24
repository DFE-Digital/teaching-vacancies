module Vacancies::Export::DwpFindAJob
  class PublishedAndUpdated
    include Vacancies::Export::DwpFindAJob::PublishedAndUpdatedVacancies

    attr_reader :from_date

    def initialize(from_date)
      @from_date = from_date
    end

    def call
      vacancies = Query.new(from_date).vacancies
      xml = Xml.new(vacancies).xml

      Upload.new(xml: xml, filename: filename).call

      Rails.logger.info("[DWP Find a Job] Uploaded '#{filename}.xml': Containing #{vacancies.size} vacancies to publish.")
    end

    private

    def filename
      @filename ||= "TeachingVacancies-upload-#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
    end
  end
end
