require 'rails_helper'

RSpec.feature 'Hiring staff can upload documents to a vacancy' do
  let(:feature_enabled?) { true }
  let(:session_id) { SecureRandom.uuid }
  let(:school) { create(:school) }
  let!(:pay_scales) { create_list(:pay_scale, 3) }
  let!(:subjects) { create_list(:subject, 3) }
  let!(:leaderships) { create_list(:leadership, 3) }
  let(:vacancy) do
    VacancyPresenter.new(build(:vacancy, :complete,
                               school: school,
                               min_pay_scale: pay_scales.sample,
                               max_pay_scale: pay_scales.sample,
                               subject: subjects[0],
                               first_supporting_subject: subjects[1],
                               second_supporting_subject: subjects[2],
                               leadership: leaderships.sample,
                               working_patterns: ['full_time', 'part_time'],
                               publish_on: Time.zone.today))
  end

  before do
    allow(UploadDocumentsFeature).to receive(:enabled?).and_return(feature_enabled?)
    stub_hiring_staff_auth(urn: school.urn)

    visit new_school_job_path
    fill_in_job_specification_form_fields(vacancy)
    click_on 'Save and continue'
  end

  context 'when the URL is accessed directly' do
    scenario 'redirects the user to the supporting documents option select page' do
      visit documents_school_job_path
      expect(page.current_path).to eq(supporting_documents_school_job_path)
    end
  end

  context "when the user selects 'yes' in the previous step" do
    before do
      visit supporting_documents_school_job_path
      fill_in_supporting_documents_form_fields(vacancy)
      click_on 'Save and continue'
    end

    scenario 'users lands on upload documents page' do
      expect(page.current_path).to eq(documents_school_job_path)
      expect(page).to have_content('Upload files')
    end

    scenario 'hiring staff can select a file for upload' do
      page.attach_file('documents-form-documents-field', Rails.root.join('spec/fixtures/files/blank_job_spec.pdf'))
      expect(page.find('#documents-form-documents-field').value).to_not be nil
    end

    scenario 'hiring staff can continue to next page' do
      click_on 'Save and continue'
      expect(page.current_path).to eq(application_details_school_job_path)
    end
  end
end
