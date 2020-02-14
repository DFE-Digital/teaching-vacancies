require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::DocumentsController, type: :controller do
    it 'redirects to the page after a successful upload' do
      # This may change as upload functionality is being defined.
      # TODO: this test currently tests nothing...
      post :create, params: { upload: fixture_file_upload(Rails.root.join('spec/fixtures/files/blank_job_spec.pdf')) }
      expect(response.status).to eq(302)
    end
end
