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

  context "without 'yes' previously selected for supporting documents" do
    scenario 'redirects to step 2, supporting documents' do
      visit documents_school_job_path
      expect(page.current_path).to eq(supporting_documents_school_job_path)
    end
  end

  context "with 'yes' previously selected for supporting documents" do
    before do
      visit supporting_documents_school_job_path
      fill_in_supporting_documents_form_fields(vacancy)
      click_on 'Save and continue'
    end

    scenario 'displays upload a file text' do
      expect(page).to have_content('Upload a file')
    end

    scenario 'hiring staff can select a file for upload' do
      page.attach_file('upload', Rails.root.join('spec/fixtures/files/blank_job_spec.pdf'))
      expect(page.find('#upload').value).to_not be nil
    end
  end
end
