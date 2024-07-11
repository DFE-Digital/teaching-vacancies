require "nokogiri"

module Vacancies::Export::DwpFindAJob::ClosedEarlyVacancies
  class Xml
    include Vacancies::Export::DwpFindAJob::Versioning

    attr_reader :vacancies

    def initialize(vacancies)
      @vacancies = vacancies
    end

    def xml
      return if vacancies.none?

      Nokogiri::XML::Builder.new(encoding: "UTF-8") { |xml|
        xml.ExpireVacancies do
          vacancies.each do |vacancy|
            xml.ExpireVacancy(vacancyRefCode: versioned_reference(vacancy))
          end
        end
      }.to_xml
    end
  end
end
