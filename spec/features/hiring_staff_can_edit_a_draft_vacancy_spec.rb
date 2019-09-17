require 'rails_helper'
RSpec.feature 'Hiring staff can edit a draft vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'when user returns to edit a draft vacancy within the same session' do
    let!(:pay_scales) { create_list(:pay_scale, 3) }
    let!(:subjects) { create_list(:subject, 3) }
    let!(:leaderships) { create_list(:leadership, 3) }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy, :complete,
                                 job_title: 'Draft vacancy',
                                 school: school,
                                 min_pay_scale: pay_scales.sample,
                                 max_pay_scale: pay_scales.sample,
                                 subject: subjects[0],
                                 first_supporting_subject: subjects[1],
                                 second_supporting_subject: subjects[2],
                                 leadership: leaderships.sample,
                                 working_patterns: ['full_time', 'part_time']))
    end
    let(:draft_vacancy) { Vacancy.find_by(job_title: vacancy.job_title) }
    let(:published_vacancy) { create(:vacancy, :published, school: school) }

    before do
      visit new_school_job_path
      fill_in_job_specification_form_fields(vacancy)
      click_on 'Save and continue'

      fill_in 'candidate_specification_form[education]', with: 'Teaching degree'
      fill_in 'candidate_specification_form[qualifications]', with: 'New Teacher Qualification'
      click_on 'Save and continue'
    end

    scenario 'redirects to incomplete step and prepopulates any completed fields' do
      expect(page).to have_content("can\'t be blank")

      visit school_path

      visit school_job_path(id: draft_vacancy.id)

      expect(page).to have_content('Teaching degree')
      expect(page).to have_content('New Teacher Qualification')

      within('#candidate_specification_form_experience') do
        expect(page).to have_content('')
      end
    end

    scenario 'redirects to incomplete step with no fields prepopulated, if a different vacancy editing session was attempted' do
      # When you attempt to edit another vacancy and save,
      # it will overwrite the vacancy attributes currently in the session.

      visit edit_school_job_path(published_vacancy.id)
      click_link_in_container_with_text(I18n.t('jobs.application_link'))
      published_vacancy.application_link = 'https://tvs.com'

      fill_in 'application_details_form[application_link]', with: published_vacancy.application_link
      click_on 'Update job'

      expect(page).to have_content(I18n.t('messages.jobs.updated'))

      visit school_job_path(id: draft_vacancy.id)

      expect(page).to have_content('Step 2 of 3')
    end
  end
end