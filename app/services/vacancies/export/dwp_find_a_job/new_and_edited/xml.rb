require "nokogiri"

module Vacancies::Export::DwpFindAJob::NewAndEdited
  class Xml
    APPLY_VIA_EXTERNAL_URL_ID = 2

    attr_reader :vacancies

    def initialize(vacancies)
      @vacancies = vacancies
    end

    def xml
      return if vacancies.none?

      Nokogiri::XML::Builder.new(encoding: "UTF-8") { |xml|
        xml.Vacancies do
          vacancies.each { |vacancy| vacancy_to_xml(vacancy, xml) }
        end
      }.to_xml
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def vacancy_to_xml(vacancy, xml)
      org = vacancy.organisation
      return if org&.postcode.blank? # Poscode is mandatory in "Find A Job" service

      vacancy = ParsedVacancy.new(vacancy)

      xml.Vacancy(vacancyRefCode: vacancy.id) do
        xml.Title vacancy.job_title
        xml.Description vacancy.description
        xml.Location do
          xml.StreetAddress org.address if org.address.present?
          xml.City org.town if org.town.present?
          xml.State org.county if org.county.present?
          xml.PostalCode org.postcode
        end
        if (expiry = vacancy.expiry)
          xml.VacancyExpiry expiry
        end
        xml.VacancyType(id: vacancy.type_id)
        xml.VacancyStatus(id: vacancy.status_id)
        xml.VacancyCategory(id: vacancy.category_id)
        xml.ApplyMethod(id: APPLY_VIA_EXTERNAL_URL_ID)
        xml.ApplyUrl vacancy.apply_url
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
