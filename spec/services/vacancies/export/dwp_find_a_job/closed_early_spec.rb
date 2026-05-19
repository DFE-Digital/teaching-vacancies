require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::ClosedEarly do
  describe "#call" do
    subject { described_class.new("2024-05-01") }

    let(:vacancy_manually_expired) { build_stubbed(:vacancy) }
    let(:vacancy_manually_expired2) { build_stubbed(:vacancy) }

    let(:sftp_session) { instance_double(Net::SFTP::Session, upload!: true) }
    let(:tempfile) { instance_double(Tempfile, path: "/tmp/#{filename}", flush: true, close!: true, write: true) }
    let(:filename) { "TeachingVacancies-expire-20240502-010444" }

    before do
      travel_to(Time.zone.local(2024, 5, 2, 1, 4, 44))

      allow(Vacancies::Export::DwpFindAJob::ClosedEarlyVacancies::Query)
        .to receive(:new)
              .and_return(instance_double(Vacancies::Export::DwpFindAJob::ClosedEarlyVacancies::Query, vacancies: [vacancy_manually_expired, vacancy_manually_expired2]))
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
