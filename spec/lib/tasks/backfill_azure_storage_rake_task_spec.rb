require "rails_helper"

# rubocop:disable RSpec/NamedSubject
RSpec.describe "backfill_azure_storage" do
  include_context "rake"

  let!(:document1_blob) do
    ActiveStorage::Blob.create!(
      key: "document1",
      filename: "test_document.pdf",
      content_type: "application/pdf",
      byte_size: 1024,
      checksum: "abc123",
      service_name: "amazon_s3_documents",
    )
  end

  let!(:document2_blob) do
    ActiveStorage::Blob.create!(
      key: "document2",
      filename: "another_document.pdf",
      content_type: "application/pdf",
      byte_size: 2048,
      checksum: "def456",
      service_name: "amazon_s3_documents",
    )
  end

  let!(:logo1_blob) do
    ActiveStorage::Blob.create!(
      key: "logo1",
      filename: "logo.png",
      content_type: "image/png",
      byte_size: 512,
      checksum: "ghi789",
      service_name: "amazon_s3_images_and_logos",
    )
  end

  let!(:already_migrated_document_blob) do
    ActiveStorage::Blob.create!(
      key: "already_migrated",
      filename: "already.pdf",
      content_type: "application/pdf",
      byte_size: 1024,
      checksum: "jkl012",
      service_name: "mirror_documents",
    )
  end

  after do
    subject.reenable
  end

  it "updates service names from amazon_s3_documents to mirror_documents" do
    expect {
      expect { subject.invoke }.to output.to_stdout
    }.to change { ActiveStorage::Blob.where(service_name: "amazon_s3_documents").count }.from(2).to(0)
      .and change { ActiveStorage::Blob.where(service_name: "mirror_documents").count }.from(1).to(3)
  end

  it "updates service names from amazon_s3_images_and_logos to mirror_images_and_logos" do
    expect {
      expect { subject.invoke }.to output.to_stdout
    }.to change { ActiveStorage::Blob.where(service_name: "amazon_s3_images_and_logos").count }.from(1).to(0)
      .and change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count }.from(0).to(1)
  end

  it "outputs how many blobs are going to be migrated for each service" do
    expect { subject.invoke }
      .to output(/Found 2 blob\(s\) to migrate.*Found 1 blob\(s\) to migrate/m)
      .to_stdout
  end

  it "queues mirror jobs for all blobs using mirror services" do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(ActiveStorage::Blob).to receive(:mirror_later)
    # Stub find_each to yield our mocked instances instead of fresh DB instances
    allow_any_instance_of(ActiveRecord::Relation).to receive(:find_each) do |&block|
      [document1_blob, document2_blob, logo1_blob, already_migrated_document_blob].each { |blob| block.call(blob) }
    end
    # rubocop:enable RSpec/AnyInstance

    expect { subject.invoke }.to output(/Queued 4 blob\(s\) for mirroring/).to_stdout
    expect([document1_blob, document2_blob, logo1_blob, already_migrated_document_blob]).to all(have_received(:mirror_later))
  end

  context "when there are no blobs for a service" do
    before do
      ActiveStorage::Blob.where(service_name: "amazon_s3_images_and_logos").delete_all
    end

    it "skips migration for that service" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "amazon_s3_documents").count }.from(2).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "mirror_documents").count }.from(1).to(3)
    end

    it "outputs message when no blobs found" do
      expect { subject.invoke }.to output(/No blobs found for service 'amazon_s3_images_and_logos'/).to_stdout
    end
  end

  context "when there are no blobs to mirror" do
    before do
      ActiveStorage::Blob.delete_all
    end

    it "outputs message when no blobs are found for mirroring" do
      expect { subject.invoke }.to output(/No blobs found for mirroring/).to_stdout
    end

    it "reports zero mirror jobs queued" do
      expect { subject.invoke }.to output(/Mirror jobs queued: 0/).to_stdout
    end
  end

  context "when only images and logos need migration" do
    before do
      ActiveStorage::Blob.where(service_name: "amazon_s3_documents").delete_all
    end

    it "migrates only the images and logos service" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "amazon_s3_images_and_logos").count }.from(1).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count }.from(0).to(1)
    end
  end
end
# rubocop:enable RSpec/NamedSubject
