require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::Upload do
  describe "#call" do
    subject { described_class.new(xml:, filename:) }

    let(:sftp_session) { instance_double(Net::SFTP::Session, upload!: true) }
    let(:tempfile) { instance_double(Tempfile, path: "/tmp/#{filename}", flush: true, close!: true, write: true) }
    let(:filename) { "TeachingVacancies-upload-20240502-010444" }
    let(:xml) { "<Vacancies></Vacancies>" }

    before do
      allow(Tempfile).to receive(:new).with(filename).and_return(tempfile)
      allow(Net::SFTP).to receive(:start).and_yield(sftp_session)
    end

    it "writes the xml content into a tempfile with the given filename" do
      subject.call
      expect(tempfile).to have_received(:write).with(xml)
    end

    it "uploads the XML file to the SFTP server" do
      subject.call
      expect(sftp_session).to have_received(:upload!).with(%r{^/tmp/#{filename}}, "Inbound/#{filename}.xml")
    end

    it "ensures the file has been closed and unlinked after the upload" do
      subject.call
      expect(tempfile).to have_received(:close!)
    end

    context "when there is an error during the upload" do
      before do
        allow(sftp_session).to receive(:upload!).and_raise(Net::SFTP::Exception)
      end

      it "ensures the file has been closed and unlinked after the upload" do
        expect { subject.call }.to raise_error(Net::SFTP::Exception)
        expect(tempfile).to have_received(:close!)
      end
    end
  end
end
