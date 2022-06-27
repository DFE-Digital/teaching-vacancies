require "rails_helper"

RSpec.describe Publishers::DocumentVirusCheck do
  subject { described_class.new(file) }

  let(:file) { double("File", path: "/dev/null") }
  let(:uploaded_file) { double("Uploaded file", id: "0xDECAFBAD") }
  let(:drive_service) { double("GDrive", create_file: uploaded_file, get_file: nil, delete_file: nil) }

  let(:time) { Time.zone.local(1999, 12, 31, 23, 59, 59) }

  before do
    allow(Google::Apis::DriveV3::DriveService).to receive(:new).and_return(drive_service)
  end

  describe "#safe?" do
    it "uploads the file to Google Drive with a timestamped filename" do
      expect(drive_service).to receive(:create_file)
        .with(
          hash_including(name: "virus-check-1999-12-31-23.59.59.000"),
          hash_including(upload_source: "/dev/null"),
        )

      travel_to(time) { subject.safe? }
    end

    context "when the file downloads fine" do
      before do
        expect(drive_service).to receive(:get_file)
          .with("0xDECAFBAD", acknowledge_abuse: false, download_dest: "0xDECAFBAD")
          .and_return(true)
      end

      it "considers the file safe" do
        expect(subject).to be_safe
      end

      it "deletes the temporary downloaded file and the file on Google Drive" do
        expect(drive_service).to receive(:delete_file).with("0xDECAFBAD")
        expect(FileUtils).to receive(:rm_rf).with("0xDECAFBAD").and_return(true)

        subject.safe?
      end
    end

    context "when the file does not download due to a virus" do
      before do
        expect(drive_service).to receive(:get_file)
          .with("0xDECAFBAD", acknowledge_abuse: false, download_dest: "0xDECAFBAD")
          .and_raise(Google::Apis::ClientError.new("Whoops", status_code: 403))
      end

      it "considers the file unsafe" do
        expect(subject).not_to be_safe
      end

      it "deletes the file from Google Drive" do
        expect(drive_service).to receive(:delete_file).with("0xDECAFBAD")

        subject.safe?
      end
    end

    context "when the file does not download due to another error" do
      let(:error) { Google::Apis::ClientError.new("Out to lunch") }

      before do
        expect(drive_service).to receive(:get_file)
          .with("0xDECAFBAD", acknowledge_abuse: false, download_dest: "0xDECAFBAD")
          .and_raise(error)
      end

      it "re-raises the error and deletes the file from Google Drive" do
        expect(drive_service).to receive(:delete_file).with("0xDECAFBAD")

        expect { subject.safe? }.to raise_error(error)
      end
    end
  end
end
