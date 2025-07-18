require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::ClosedEarly do
  describe "#call" do
    subject { described_class.new("2024-05-01") }

    let(:vacancy_expired_old) { create(:vacancy, publish_on: 4.days.ago, expires_at: 2.days.ago) }
    let(:vacancy_manually_expired) do
      create(:vacancy,
             id: "ff7af59b-558b-4c55-9941-fe1942d84984",
             publish_on: 1.week.ago,
             updated_at: 10.minutes.ago,
             expires_at: 10.minutes.ago,
             created_at: 2.weeks.ago)
    end
    let(:vacancy_manually_expired2) do
      create(:vacancy,
             id: "ac54642c-1679-4a86-9d00-7ed7e54c751e",
             publish_on: 1.week.ago,
             updated_at: 45.seconds.ago,
             expires_at: 1.minute.ago,
             created_at: 1.week.ago)
    end
    let(:vacancy_naturally_expired) do
      create(:vacancy,
             id: "0ee558c1-3587-4f7a-a0c2-d40a2289c7fe",
             publish_on: 1.week.ago,
             updated_at: 1.week.ago,
             expires_at: 10.minutes.ago,
             created_at: 2.weeks.ago)
    end

    let(:sftp_session) { instance_double(Net::SFTP::Session, upload!: true) }
    let(:tempfile) { instance_double(Tempfile, path: "/tmp/#{filename}", flush: true, close!: true, write: true) }
    let(:filename) { "TeachingVacancies-expire-20240502-010444" }

    before do
      travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))
      vacancy_expired_old
      vacancy_manually_expired
      vacancy_manually_expired2
      vacancy_naturally_expired

      allow(Tempfile).to receive(:new).with(filename).and_return(tempfile)
      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    after do
      travel_back
    end

    it "generates an XML with the vacancies manually closed after the given date" do
      subject.call
      expect(tempfile).to have_received(:write).with(
        <<~XML,
          <?xml version="1.0" encoding="UTF-8"?>
          <ExpireVacancies>
            <ExpireVacancy vacancyRefCode="#{vacancy_manually_expired.id}"/>
            <ExpireVacancy vacancyRefCode="#{vacancy_manually_expired2.id}"/>
          </ExpireVacancies>
        XML
      )
    end

    it "uploads the XML file to the SFTP server" do
      subject.call
      expect(sftp_session).to have_received(:upload!).with(%r{^/tmp/#{filename}}, "Inbound/#{filename}.xml")
    end

    it "logs the upload" do
      expect(Rails.logger).to receive(:info).with("[DWP Find a Job] Uploaded '#{filename}.xml': Containing 2 vacancies to close.")
      subject.call
    end
  end
end
