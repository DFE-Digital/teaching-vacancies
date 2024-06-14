require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::ExpiredAndDeleted::Upload do
  describe "#call" do
    let(:vacancy_expired_old) { create(:vacancy, :published, publish_on: 4.days.ago, expires_at: 2.days.ago) }
    let(:vacancy_manually_expired) do
      create(:vacancy,
             :published,
             id: "ff7af59b-558b-4c55-9941-fe1942d84984",
             publish_on: 1.week.ago,
             updated_at: 10.minutes.ago,
             expires_at: 10.minutes.ago,
             created_at: 2.weeks.ago)
    end
    let(:vacancy_manually_expired2) do
      create(:vacancy,
             :published,
             id: "ac54642c-1679-4a86-9d00-7ed7e54c751e",
             publish_on: 1.week.ago,
             updated_at: 45.seconds.ago,
             expires_at: 1.minute.ago,
             created_at: 1.week.ago)
    end
    let(:vacancy_naturally_expired) do
      create(:vacancy,
             :published,
             id: "0ee558c1-3587-4f7a-a0c2-d40a2289c7fe",
             publish_on: 1.week.ago,
             updated_at: 1.week.ago,
             expires_at: 10.minutes.ago,
             created_at: 2.weeks.ago)
    end

    let(:sftp_session) { instance_double(Net::SFTP::Session, upload!: true) }
    let(:file_name) { "TeachingVacancies-expire-20240502-010444" }

    subject { described_class.new("2024-05-01") }

    before do
      travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))
      vacancy_expired_old
      vacancy_manually_expired
      vacancy_manually_expired2
      vacancy_naturally_expired

      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    after do
      travel_back
    end

    it "generates an XML with the vacancies manually expired after the given date" do
      tempfile = instance_double(Tempfile, path: "/tmp/#{file_name}", flush: true, close!: true)
      expect(Tempfile).to receive(:new).with(file_name).and_return(tempfile)
      expect(tempfile).to receive(:write).with(
        <<~XML,
          <?xml version="1.0" encoding="UTF-8"?>
          <ExpireVacancies>
            <ExpireVacancy vacancyRefCode="#{vacancy_manually_expired.id}"/>
            <ExpireVacancy vacancyRefCode="#{vacancy_manually_expired2.id}"/>
          </ExpireVacancies>
        XML
      )

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
