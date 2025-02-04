require "rails_helper"

RSpec.describe Publishers::DocumentVirusCheck do
  subject { described_class.new(file) }

  let(:file) { instance_double(File, path: "/dev/null") }
  let(:uploaded_file) { instance_double(Google::Apis::DriveV3::File, id: "0xDECAFBAD") }
  let(:time) { Time.zone.local(1999, 12, 31, 23, 59, 59) }
  let(:authorization) { instance_double(Google::Auth::ServiceAccountCredentials, fetch_access_token!: true) }
  let(:google_api_client) { instance_double(GoogleApiClient, missing_key?: false, authorization: authorization) }
  let(:drive_service) do
    instance_double(Google::Apis::DriveV3::DriveService,
                    create_file: uploaded_file,
                    get_file: nil,
                    delete_file: nil,
                    "authorization=": authorization)
  end

  before do
    allow(GoogleApiClient).to receive(:instance).and_return(google_api_client)
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

    context "when the api client is missing the API key" do
      let(:google_api_client) { instance_double(GoogleApiClient, missing_key?: true, authorization: nil) }

      it "returns false" do
        expect(subject).not_to be_safe
      end

      it "does not attempt to upload the file" do
        expect(Google::Apis::DriveV3::DriveService).not_to receive(:new)

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
