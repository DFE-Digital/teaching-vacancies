require "rails_helper"

# rubocop:disable RSpec/NamedSubject
# rubocop:disable RSpec/ExpectOutput
RSpec.describe "find_and_mirror_s3_blobs" do
  include_context "rake"

  around do |test|
    original_stdout = $stdout
    $stdout = StringIO.new
    test.run
  ensure
    $stdout = original_stdout
  end

  def relation_with_batches(*batches)
    relation = instance_double(ActiveRecord::Relation)
    allow(relation).to receive(:find_in_batches).with(batch_size: 1000) do |&block|
      batches.each { |batch| block.call(batch) }
    end
    relation
  end

  def azure_relation_with_keys(keys)
    relation = instance_double(ActiveRecord::Relation)
    allow(relation).to receive(:where).and_return(relation)
    allow(relation).to receive(:pluck).with(:key).and_return(keys)
    relation
  end

  def setup_blob_stubs(s3_documents: [], s3_images: [], azure_document_keys: [], azure_image_keys: [])
    allow(ActiveStorage::Blob).to receive(:where).and_call_original
    allow(ActiveStorage::Blob).to receive(:where).with(service_name: "amazon_s3_documents").and_return(relation_with_batches(*s3_documents))
    allow(ActiveStorage::Blob).to receive(:where).with(service_name: "amazon_s3_images_and_logos").and_return(relation_with_batches(*s3_images))
    allow(ActiveStorage::Blob).to receive(:where).with(service_name: "azure_storage_documents").and_return(azure_relation_with_keys(azure_document_keys))
    allow(ActiveStorage::Blob).to receive(:where).with(service_name: "azure_storage_images_and_logos").and_return(azure_relation_with_keys(azure_image_keys))
  end

  describe "with S3 blobs but no Azure blobs" do
    let!(:document_first) do
      ActiveStorage::Blob.create!(
        key: "document1",
        filename: "document.pdf",
        content_type: "application/pdf",
        byte_size: 1024,
        checksum: "abc123",
        service_name: "amazon_s3_documents",
      )
    end

    let!(:document_second) do
      ActiveStorage::Blob.create!(
        key: "document2",
        filename: "another_document.pdf",
        content_type: "application/pdf",
        byte_size: 2048,
        checksum: "def456",
        service_name: "amazon_s3_documents",
      )
    end

    let!(:logo_first) do
      ActiveStorage::Blob.create!(
        key: "logo1",
        filename: "logo.png",
        content_type: "image/png",
        byte_size: 512,
        checksum: "jkl012",
        service_name: "amazon_s3_images_and_logos",
      )
    end

    let!(:logo_second) do
      ActiveStorage::Blob.create!(
        key: "logo2",
        filename: "icon.png",
        content_type: "image/png",
        byte_size: 256,
        checksum: "mno345",
        service_name: "amazon_s3_images_and_logos",
      )
    end

    before do
      setup_blob_stubs(s3_documents: [[document_first, document_second]], s3_images: [[logo_first, logo_second]])
    end

    it "queues all S3 blobs for mirroring" do
      expect(document_first).to receive(:mirror_later).once
      expect(document_second).to receive(:mirror_later).once
      expect(logo_first).to receive(:mirror_later).once
      expect(logo_second).to receive(:mirror_later).once

      subject.execute
    end
  end

  describe "with one S3 document blob" do
    let!(:unmirored_document) do
      ActiveStorage::Blob.create!(
        key: "unmirored1",
        filename: "new.pdf",
        content_type: "application/pdf",
        byte_size: 1024,
        checksum: "new123",
        service_name: "amazon_s3_documents",
      )
    end

    before do
      setup_blob_stubs(s3_documents: [[unmirored_document]])
    end

    it "queues one mirror job" do
      expect(unmirored_document).to receive(:mirror_later).once

      subject.execute
    end
  end

  describe "with no S3 blobs" do
    before do
      setup_blob_stubs
    end

    it "does not queue any mirror jobs" do
      expect(ActiveStorage::Blob).not_to receive(:find)

      subject.execute
    end
  end

  describe "with only S3 document blobs" do
    let!(:document_blob) do
      ActiveStorage::Blob.create!(
        key: "doc1",
        filename: "test.pdf",
        content_type: "application/pdf",
        byte_size: 1024,
        checksum: "abc123",
        service_name: "amazon_s3_documents",
      )
    end

    before do
      setup_blob_stubs(s3_documents: [[document_blob]])
    end

    it "queues the document blob for mirroring" do
      expect(document_blob).to receive(:mirror_later).once

      subject.execute
    end
  end

  describe "with only S3 image blobs" do
    let!(:logo_blob) do
      ActiveStorage::Blob.create!(
        key: "logo1",
        filename: "logo.png",
        content_type: "image/png",
        byte_size: 512,
        checksum: "jkl012",
        service_name: "amazon_s3_images_and_logos",
      )
    end

    before do
      setup_blob_stubs(s3_images: [[logo_blob]])
    end

    it "queues the image blob for mirroring" do
      expect(logo_blob).to receive(:mirror_later).once

      subject.execute
    end
  end

  describe "when a batch has no unmirored blobs" do
    let!(:already_synced_document) do
      ActiveStorage::Blob.create!(
        key: "already_synced_doc",
        filename: "already_synced.pdf",
        content_type: "application/pdf",
        byte_size: 1024,
        checksum: "synced123",
        service_name: "amazon_s3_documents",
      )
    end

    before do
      setup_blob_stubs(s3_documents: [[already_synced_document]], azure_document_keys: %w[already_synced_doc])
    end

    it "does not queue mirror jobs for that batch" do
      expect(already_synced_document).not_to receive(:mirror_later)

      subject.execute
    end
  end
end
# rubocop:enable RSpec/ExpectOutput
# rubocop:enable RSpec/NamedSubject
