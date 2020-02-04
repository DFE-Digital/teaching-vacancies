require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::DocumentsController, type: :controller do
    it 'uploads file to controller' do
        post :create, params: { upload: fixture_file_upload(Rails.root.join('spec/fixtures/files/blank_job_spec.pdf')) }
        expect(response.status).to eq(302)
    end
end