require 'rails_helper'

RSpec.describe DocumentDelete do
  subject { described_class.new(document_stub) }

  let(:drive_service_stub) { double(Google::Apis::DriveV3::DriveService) }
  let(:document_stub) { double(Document, google_drive_id: google_drive_id) }

  let(:google_drive_id) { 'abcde' }

  before do
    allow(Google::Apis::DriveV3::DriveService).to receive(:new).and_return(drive_service_stub)
    allow(drive_service_stub).to receive(:delete_file)
    allow(document_stub).to receive(:destroy)
  end

  it 'raises MissingUploadPath error when document is nil' do
    expect { described_class.new(nil) }.to raise_error(described_class::MissingDocument)
  end

  context 'delete' do
    it 'calls delete_file on drive_service' do
      expect(drive_service_stub).to receive(:delete_file).with(google_drive_id)

      subject.delete
    end

    it 'calls destroy on document' do
      expect(document_stub).to receive(:destroy)

      subject.delete
    end

    context 'when an exception is thrown' do
      let(:google_apis_exception) { Google::Apis::ClientError.new('genericError', status_code: 500) }

      before do
        expect(drive_service_stub).to receive(:delete_file).and_raise(google_apis_exception)
      end

      it 'does not destroy document' do
        expect(document_stub).not_to receive(:destroy)

        expect { subject.delete }.to raise_error(google_apis_exception)
      end

      context 'when file does not exist' do
        let(:google_apis_exception) { Google::Apis::ClientError.new('notFound', status_code: 404) }

        it 'calls destroy on document' do
          expect(document_stub).to receive(:destroy)

          subject.delete
        end
      end
    end
  end
end
