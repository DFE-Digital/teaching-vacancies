require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::NewAndEdited::Upload do
  describe "#call" do
    let(:org) { create(:school, address: "1 School Lane", town: "School Town", county: "School County", postcode: "AB12 3CD") }
    let(:vacancy_published_old) do
      create(:vacancy,
             :published,
             publish_on: 2.days.ago,
             created_at: 2.days.ago,
             updated_at: 2.days.ago,
             expires_at: 40.days.after)
    end
    let(:vacancy_published) do
      create(:vacancy,
             :published,
             id: "ff7af59b-558b-4c55-9941-fe1942d84984",
             publish_on: 1.hour.ago,
             updated_at: 2.weeks.ago,
             created_at: 2.weeks.ago,
             job_title: "Great teacher",
             job_advert: "We need a great teacher",
             expires_at: Time.zone.local(2024, 5, 17, 9, 0, 0),
             working_patterns: ["full_time"],
             job_roles: ["teacher"],
             contract_type: "permanent",
             slug: "great-teacher",
             organisations: [org])
    end
    let(:vacancy_updated) do
      create(:vacancy,
             :published,
             id: "0ee558c1-3587-4f7a-a0c2-d40a2289c7fe",
             publish_on: 2.days.ago,
             updated_at: 1.hour.ago,
             created_at: 1.hour.ago,
             job_title: "IT technician",
             job_advert: "IT technician for school",
             expires_at: Time.zone.local(2024, 5, 20, 9, 0, 0),
             working_patterns: ["part_time"],
             job_roles: ["it_support"],
             contract_type: "fixed_term",
             slug: "it-technician",
             organisations: [org])
    end

    let(:expected_xml_content) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <Vacancies>
          <Vacancy vacancyRefCode="#{vacancy_published.id}">
            <Title>Great teacher</Title>
            <Description>We need a great teacher</Description>
            <Location>
              <StreetAddress>1 School Lane</StreetAddress>
              <City>School Town</City>
              <State>School County</State>
              <PostalCode>AB12 3CD</PostalCode>
            </Location>
            <VacancyExpiry>2024-05-17</VacancyExpiry>
            <VacancyType id="1"/>
            <VacancyStatus id="1"/>
            <VacancyCategory id="27"/>
            <ApplyMethod id="2"/>
            <ApplyUrl>http://#{DOMAIN}/jobs/great-teacher</ApplyUrl>
          </Vacancy>
          <Vacancy vacancyRefCode="#{vacancy_updated.id}">
            <Title>IT technician</Title>
            <Description>IT technician for school</Description>
            <Location>
              <StreetAddress>1 School Lane</StreetAddress>
              <City>School Town</City>
              <State>School County</State>
              <PostalCode>AB12 3CD</PostalCode>
            </Location>
            <VacancyExpiry>2024-05-20</VacancyExpiry>
            <VacancyType id="2"/>
            <VacancyStatus id="2"/>
            <VacancyCategory id="14"/>
            <ApplyMethod id="2"/>
            <ApplyUrl>http://#{DOMAIN}/jobs/it-technician</ApplyUrl>
          </Vacancy>
        </Vacancies>
      XML
    end

    let(:sftp_session) { instance_double(Net::SFTP::Session, upload!: true) }
    let(:file_name) { "TeachingVacancies-upload-20240502-010444" }

    subject { described_class.new("2024-05-01") }

    before do
      travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))
      vacancy_published_old
      vacancy_published
      vacancy_updated

      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    after do
      travel_back
    end

    it "generates an XML with the vacancies published/edited after the given date" do
      tempfile = instance_double(Tempfile, path: "/tmp/#{file_name}")
      expect(Tempfile).to receive(:open).with(file_name).and_yield(tempfile)
      expect(tempfile).to receive(:write).with(expected_xml_content)

      subject.call
    end

    it "uploads the XML file to the SFTP server" do
      expect(sftp_session).to receive(:upload!).with(%r{^/tmp/#{file_name}}, "Inbound/#{file_name}.xml")
      subject.call
    end

    it "logs the upload" do
      expect(Rails.logger).to receive(:info).with("[DWP Find a Job] Uploaded '#{file_name}.xml': Containing 2 vacancies.")
      subject.call
    end
  end
end
