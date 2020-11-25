require "rails_helper"

RSpec.describe DocumentCopy do
  subject { described_class.new(document_id) }

  let(:copy_file) { double("copy_file") }
  let(:document_id) { "test_id" }

  it "raises MissingDocumentId error when called without an argument" do
    expect { described_class.new(nil) }.to raise_error(described_class::MissingDocumentId)
  end

  context "copy_publishers_document" do
    it "calls copy_file on drive_service with document id" do
      expect(subject.drive_service).to receive(:copy_file).with(
        document_id,
        anything,
      )
      subject.copy_publishers_document
    end
  end

  context "set_public_permission_on_document" do
    before do
      allow(subject).to receive(:copied).and_return(copy_file)
    end

    it "calls create_permission on drive_service" do
      allow(copy_file).to receive(:id)
      expect(subject.drive_service).to receive(:create_permission).with(
        anything,
        anything,
      )
      subject.set_public_permission_on_document
    end

    it "calls create_permission with id returned by create_file call" do
      expect(copy_file).to receive(:id)
      allow(subject.drive_service).to receive(:create_permission)
      subject.set_public_permission_on_document
    end

    it "calls create_permission with Google::Apis::DriveV3::Permission" do
      allow(copy_file).to receive(:id)
      allow(subject.drive_service).to receive(:create_permission)
      expect(Google::Apis::DriveV3::Permission).to receive(:new).with(
        type: "anyone", role: "reader",
      )
      subject.set_public_permission_on_document
    end
  end
end
