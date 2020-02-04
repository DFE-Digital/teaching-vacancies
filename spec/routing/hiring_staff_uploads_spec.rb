require 'rails_helper'

RSpec.describe 'Hiring staff document upload routing' do
  before do
    allow(ENV).to receive(:[])
  end

  context 'ENV["FEATURE_UPLOAD_DOCUMENTS"] == true' do
    before do
      allow(UploadDocumentsFeature).to receive(:enabled?).and_return(true)
    end

    it {
      expect(get: '/school/job/documents').to route_to(
        controller: 'hiring_staff/vacancies/documents',
        action: 'new',
      )
    }
  end

  context 'ENV["FEATURE_UPLOAD_DOCUMENTS"] == false' do
    before do
      allow(UploadDocumentsFeature).to receive(:enabled?).and_return(false)
    end

    it {
      expect(get: '/school/job/documents').to route_to(
        controller: 'errors',
        action: 'not_found',
        path: 'school/job/documents'
      )
    }
  end
end
