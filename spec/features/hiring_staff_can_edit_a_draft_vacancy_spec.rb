require 'rails_helper'
RSpec.feature 'Hiring staff can edit a draft vacancy' do
  let(:school) { create(:school) }

  let(:feature_enabled?) { false }

  before do
    allow(UploadDocumentsFeature).to receive(:enabled?).and_return(feature_enabled?)

    stub_hiring_staff_auth(urn: school.urn)
  end

  context 'with job specification completed' do
    let!(:vacancy) do
      pay_scales = create_list(:pay_scale, 3)
      VacancyPresenter.new(build(:vacancy, :complete,
                                 job_title: 'Draft vacancy',
                                 school: school,
                                 min_pay_scale: pay_scales.sample,
                                 max_pay_scale: pay_scales.sample,
                                 working_patterns: ['full_time', 'part_time']))
    end
    let(:draft_vacancy) { Vacancy.find_by(job_title: vacancy.job_title) }

    before do
      visit new_school_jobs_path
      fill_in_job_specification_form_fields(vacancy)
      click_on I18n.t('buttons.save_and_continue')
    end

    scenario 'redirects to incomplete candidate specification step, with fields pre-populated' do
      draft_vacancy.education = 'Teaching degree'
      draft_vacancy.qualifications = 'New Teacher Qualification'
      draft_vacancy.save(validate: false)

      visit school_job_edit_path(job_id: draft_vacancy.id)

      expect(page).to have_content('Step 2 of 3')
      expect(page).to have_content(draft_vacancy.education)
      expect(page).to have_content(draft_vacancy.qualifications)
    end

    context 'when editing a different vacancy' do
      # We use the session to store vacancy attributes, make sure it doesn't leak between edits.
      before do
        edit_a_published_vacancy
      end

      scenario 'then editing the draft redirects to incomplete step' do
        visit school_job_path(job_id: draft_vacancy.id)
        expect(page).to have_content('Step 2 of 3')
      end

      def edit_a_published_vacancy
        published_vacancy = create(:vacancy, :published, school: school)
        visit school_job_edit_path(published_vacancy.id)
        click_link_in_container_with_text(I18n.t('jobs.application_link'))

        fill_in 'application_details_form[application_link]', with: 'https://example.com'
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
      end
    end
  end
end
