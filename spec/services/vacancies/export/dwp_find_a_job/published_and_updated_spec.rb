require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::PublishedAndUpdated do
  describe "#call" do
    subject { described_class.new("2024-05-01") }

    let(:org) do
      create(:school,
             address: "1 School Lane",
             town: "School Town",
             county: "School County",
             postcode: "AB12 3CD",
             safeguarding_information: "Safeguarding text")
    end
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
             skills_and_experience: "We need a great teacher",
             school_offer: "<p>We are a <strong>great school</strong></p><ul><li>Item 0</li><li>Item 1<ul><li>Item A<ol><li>Item i</li><li>Item ii</li></ol></li><li>Item B<ul><li>Item i</li></ul></li></ul></li><li>Item 2</li></ul><p><a href='url'>link text</a>",
             further_details: "More details",
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
             skills_and_experience: "We need a IT technician",
             school_offer: "We offer a great school",
             further_details: "More details",
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
            <Description>What skills and experience we're looking for

        We need a great teacher

        What the school offers its staff

        We are a great school

        • Item 0
        • Item 1
          • Item A
            1. Item i
            2. Item ii
          • Item B
            • Item i
        • Item 2

        link text

        Further details about the role

        More details

        Commitment to safeguarding

        Safeguarding text</Description>
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
            <Description>What skills and experience we're looking for

        We need a IT technician

        What the school offers its staff

        We offer a great school

        Further details about the role

        More details

        Commitment to safeguarding

        Safeguarding text</Description>
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
    let(:tempfile) { instance_double(Tempfile, path: "/tmp/#{filename}", flush: true, close!: true, write: true) }
    let(:filename) { "TeachingVacancies-upload-20240502-010444" }

    before do
      travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))
      vacancy_published_old
      vacancy_published
      vacancy_updated

      allow(Tempfile).to receive(:new).with(filename).and_return(tempfile)
      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    after do
      travel_back
    end

    it "generates an XML file with the vacancies published/edited after the given date" do
      subject.call
      expect(tempfile).to have_received(:write).with(expected_xml_content)
    end

    it "uploads the XML file to the SFTP server" do
      subject.call
      expect(sftp_session).to have_received(:upload!).with(%r{^/tmp/#{filename}}, "Inbound/#{filename}.xml")
    end

    it "logs the upload" do
      allow(Rails.logger).to receive(:info)

      subject.call
      expect(Rails.logger).to have_received(:info)
        .with("[DWP Find a Job] Uploaded '#{filename}.xml': Containing 2 vacancies to publish.")
    end
  end
end
