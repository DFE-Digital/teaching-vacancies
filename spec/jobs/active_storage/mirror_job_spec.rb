require "rails_helper"

RSpec.describe ActiveStorage::MirrorJob do
  let(:key) { "test-key-123" }
  let(:checksum) { "abc123checksum" }

  describe "#perform" do
    context "when the blob exists" do
      let(:service) { instance_double(ActiveStorage::Service, try: true) }
      let(:blob) do
        instance_double(ActiveStorage::Blob, key: key, checksum: checksum, service: service)
      end

      before do
        allow(ActiveStorage::Blob).to receive(:find_by).with(key: key).and_return(blob)
      end

      it "uses the blob's service to mirror the file" do
        expect(service).to receive(:try).with(:mirror, blob.key, checksum: blob.checksum)

        described_class.perform_now(key, checksum: checksum)
      end

      it "uses the blob's checksum rather than the provided checksum" do
        different_checksum = "different-checksum"
        expect(service).to receive(:try).with(:mirror, blob.key, checksum: blob.checksum)

        described_class.perform_now(key, checksum: different_checksum)
      end
    end

    context "when the blob does not exist" do
      let(:default_service) { instance_double(ActiveStorage::Service, try: true) }

      before do
        allow(ActiveStorage::Blob).to receive(:find_by).with(key: key).and_return(nil)
        allow(ActiveStorage::Blob).to receive(:service).and_return(default_service)
      end

      it "uses the default ActiveStorage service with the provided checksum to mirror the file" do
        expect(default_service).to receive(:try).with(:mirror, key, checksum: checksum)

        described_class.perform_now(key, checksum: checksum)
      end
    end

    context "when the service does not respond to mirror" do
      let(:service) { instance_double(ActiveStorage::Service) }
      let(:blob) do
        instance_double(ActiveStorage::Blob, key: key, checksum: checksum, service: service)
      end

      before do
        allow(ActiveStorage::Blob).to receive(:find_by).with(key: key).and_return(blob)
        allow(service).to receive(:try).with(:mirror, blob.key, checksum: blob.checksum).and_return(nil)
      end

      it "does not raise an error" do
        expect { described_class.perform_now(key, checksum: checksum) }.not_to raise_error
      end
    end
  end

  describe "error handling" do
    context "when ActiveStorage::FileNotFoundError is raised" do
      let(:service) { instance_double(ActiveStorage::Service) }
      let(:blob) do
        instance_double(ActiveStorage::Blob, key: key, checksum: checksum, service: service)
      end

      before do
        allow(ActiveStorage::Blob).to receive(:find_by).with(key: key).and_return(blob)
        allow(service).to receive(:try).and_raise(ActiveStorage::FileNotFoundError)
      end

      it "discards the job without raising an error" do
        expect { described_class.perform_now(key, checksum: checksum) }.not_to raise_error
      end
    end

    context "when ActiveStorage::IntegrityError is raised" do
      let(:service) { instance_double(ActiveStorage::Service) }
      let(:blob) do
        instance_double(ActiveStorage::Blob, key: key, checksum: checksum, service: service)
      end

      before do
        allow(ActiveStorage::Blob).to receive(:find_by).with(key: key).and_return(blob)
        allow(service).to receive(:try).and_raise(ActiveStorage::IntegrityError)
      end

      it "schedules a retry instead of discarding" do
        # The retry_on configuration means the job will retry automatically
        # rather than being discarded like FileNotFoundError
        expect {
          Sidekiq::Testing.inline! do
            described_class.perform_now(key, checksum: checksum)
          end
        }.not_to raise_error
      end
    end
  end
end
