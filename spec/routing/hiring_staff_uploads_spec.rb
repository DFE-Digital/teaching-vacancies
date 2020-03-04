require 'rails_helper'

RSpec.describe 'Hiring staff document upload routing' do
  let(:vacancy) do
    create(:vacancy)
  end

  before do
    allow(ENV).to receive(:[])
  end

  context 'ENV["FEATURE_UPLOAD_DOCUMENTS"] == true' do
    before do
      allow(UploadDocumentsFeature).to receive(:enabled?).and_return(true)
    end

    it {
      expect(get: school_job_documents_path(vacancy.id)).to route_to(
        controller: 'hiring_staff/vacancies/documents',
        action: 'show',
        job_id: vacancy.id
      )
    }
  end

  context 'ENV["FEATURE_UPLOAD_DOCUMENTS"] == false' do
    before do
      allow(UploadDocumentsFeature).to receive(:enabled?).and_return(false)
    end

    it {
      expect(get: school_job_documents_path(vacancy.id)).to route_to(
        controller: 'errors',
        action: 'not_found',
        path: "school/jobs/#{vacancy.id}/documents"
      )
    }
  end
end
