require "rails_helper"

# rubocop:disable RSpec/NamedSubject
RSpec.describe "point_existing_attachments_to_azure_storage" do
  include_context "rake"

  let!(:document1_blob) do # rubocop:disable RSpec/LetSetup
    ActiveStorage::Blob.create!(
      key: "mirror_document1",
      filename: "test_document.pdf",
      content_type: "application/pdf",
      byte_size: 1024,
      checksum: "abc123",
      service_name: "mirror_documents",
    )
  end

  let!(:document2_blob) do
    ActiveStorage::Blob.create!(
      key: "mirror_document2",
      filename: "another_document.pdf",
      content_type: "application/pdf",
      byte_size: 2048,
      checksum: "def456",
      service_name: "mirror_documents",
    )
  end

  let!(:logo1_blob) do # rubocop:disable RSpec/LetSetup
    ActiveStorage::Blob.create!(
      key: "mirror_logo1",
      filename: "logo.png",
      content_type: "image/png",
      byte_size: 512,
      checksum: "ghi789",
      service_name: "mirror_images_and_logos",
    )
  end

  let!(:logo2_blob) do
    ActiveStorage::Blob.create!(
      key: "mirror_logo2",
      filename: "another_logo.png",
      content_type: "image/png",
      byte_size: 256,
      checksum: "jkl012",
      service_name: "mirror_images_and_logos",
    )
  end

  after do
    subject.reenable
  end

  it "updates service names from mirror_documents to azure_storage_documents" do
    expect {
      expect { subject.invoke }.to output.to_stdout
    }.to change { ActiveStorage::Blob.where(service_name: "mirror_documents").count }.from(2).to(0)
      .and change { ActiveStorage::Blob.where(service_name: "azure_storage_documents").count }.from(0).to(2)
  end

  it "updates service names from mirror_images_and_logos to azure_storage_images_and_logos" do
    expect {
      expect { subject.invoke }.to output.to_stdout
    }.to change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count }.from(2).to(0)
      .and change { ActiveStorage::Blob.where(service_name: "azure_storage_images_and_logos").count }.from(0).to(2)
  end

  context "when there are no blobs for documents" do
    before do
      ActiveStorage::Blob.where(service_name: "mirror_documents").delete_all
    end

    it "skips migration for documents" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.not_to(change { ActiveStorage::Blob.where(service_name: "mirror_documents").count })
    end

    it "still migrates image blobs" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count }.from(2).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "azure_storage_images_and_logos").count }.from(0).to(2)
    end
  end

  context "when there are no blobs for images" do
    before do
      ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").delete_all
    end

    it "skips migration for images" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.not_to(change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count })
    end

    it "still migrates document blobs" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "mirror_documents").count }.from(2).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "azure_storage_documents").count }.from(0).to(2)
    end
  end

  context "when there are no blobs at all" do
    before do
      ActiveStorage::Blob.delete_all
    end

    it "does not change any blob counts" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.not_to(change(ActiveStorage::Blob, :count))
    end
  end

  context "when there is only one blob for each service" do
    before do
      document2_blob.destroy!
      logo2_blob.destroy!
    end

    it "migrates the single document blob" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "mirror_documents").count }.from(1).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "azure_storage_documents").count }.from(0).to(1)
    end

    it "migrates the single image blob" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count }.from(1).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "azure_storage_images_and_logos").count }.from(0).to(1)
    end
  end

  context "when only document blobs exist" do
    before do
      ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").delete_all
    end

    it "migrates only document blobs" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "mirror_documents").count }.from(2).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "azure_storage_documents").count }.from(0).to(2)
    end
  end

  context "when only image blobs exist" do
    before do
      ActiveStorage::Blob.where(service_name: "mirror_documents").delete_all
    end

    it "migrates only image blobs" do
      expect {
        expect { subject.invoke }.to output.to_stdout
      }.to change { ActiveStorage::Blob.where(service_name: "mirror_images_and_logos").count }.from(2).to(0)
        .and change { ActiveStorage::Blob.where(service_name: "azure_storage_images_and_logos").count }.from(0).to(2)
    end
  end
end
# rubocop:enable RSpec/NamedSubject
