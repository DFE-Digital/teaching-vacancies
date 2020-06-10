require 'rails_helper'

RSpec.describe DocumentUpload do
  subject { described_class.new(upload_path: upload_path, name: name) }

  let(:drive_service_stub) { double(Google::Apis::DriveV3::DriveService) }
  let(:create_file) { double('create_file') }
  let(:upload_path) { 'test.pdf' }
  let(:name) { 'Test file' }

  it 'raises MissingUploadPath error when called without an argument' do
    expect { described_class.new }.to raise_error(described_class::MissingUploadPath)
  end

  context 'upload_hiring_staff_document' do
    it 'calls create_file on drive_service' do
      expect(subject.drive_service).to receive(:create_file).with(
        { alt: 'media', name:  name },
        fields: 'id, web_view_link, web_content_link, mime_type',
        upload_source: anything()
      )
      subject.upload_hiring_staff_document
    end

    it 'explicity expects the temporary file path' do
      expect(subject.drive_service).to receive(:create_file).with(
        anything(),
        hash_including(upload_source: upload_path)
      )
      subject.upload_hiring_staff_document
    end
  end

  context 'set_public_permission_on_document' do
    before do
      allow(subject).to receive(:uploaded).and_return(create_file)
    end

    it 'calls create_permission on drive_service' do
      allow(create_file).to receive(:id)
      expect(subject.drive_service).to receive(:create_permission).with(
        anything(),
        anything()
      )
      subject.set_public_permission_on_document
    end

    it 'calls create_permission with id returned by create_file call' do
      expect(create_file).to receive(:id)
      allow(subject.drive_service).to receive(:create_permission)
      subject.set_public_permission_on_document
    end

    it 'calls create_permission with Google::Apis::DriveV3::Permission' do
      allow(create_file).to receive(:id)
      allow(subject.drive_service).to receive(:create_permission)
      expect(Google::Apis::DriveV3::Permission).to receive(:new).with(
        type: 'anyone', role: 'reader'
      )
      subject.set_public_permission_on_document
    end
  end

  context 'google_drive_virus_check' do
    let(:drive_error_stub) { double(Google::Apis::ClientError) }

    before do
      allow(subject).to receive(:uploaded).and_return(create_file)
    end

    it 'calls get_file on drive_service' do
      allow(create_file).to receive(:id)
      expect(subject.drive_service).to receive(:get_file).with(
        anything(),
        anything()
      )
      subject.google_drive_virus_check
    end

    it 'calls get_file with id returned by create_file call' do
      expect(create_file).to receive(:id).twice
      allow(subject.drive_service).to receive(:get_file)
      subject.google_drive_virus_check
    end

    it 'calls delete_file on drive_service if Google::Apis::ClientError raised' do
      allow(create_file).to receive(:id)
      # This error needs to initialised with an argument in order to be raised.
      allow(subject.drive_service).to receive(:get_file).and_raise(
        Google::Apis::ClientError.new(true, status_code: 403)
      )
      expect(subject.drive_service).to receive(:delete_file)
      subject.google_drive_virus_check
    end

    it 'calls delete_file with id returned by create_file call on drive_service if Google::Apis::ClientError raised' do
      expect(create_file).to receive(:id).exactly(3).times
      # This error needs to initialised with an argument in order to be raised.
      allow(subject.drive_service).to receive(:get_file).and_raise(
        Google::Apis::ClientError.new(true, status_code: 403)
      )
      allow(subject.drive_service).to receive(:delete_file)
      subject.google_drive_virus_check
    end
  end
end
