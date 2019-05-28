require 'rails_helper'
RSpec.feature 'Hiring staff can edit a vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'attempting to edit a draft vacancy' do
    scenario 'redirects to the review vacancy page' do
      vacancy = create(:vacancy, :draft, school: school)
      visit edit_school_job_path(vacancy.id)

      expect(page).to have_content("Review the job for #{school.name}")
    end
  end

  context 'navigation' do
    scenario 'links to the school page' do
      vacancy = create(:vacancy, :published, school: school)
      visit edit_school_job_path(vacancy.id)

      click_on school.name
      expect(page).to have_content("Jobs at #{school.name}")
    end
  end

  context 'editing a published vacancy' do
    scenario 'All vacancy information is shown' do
      vacancy = create(:vacancy, :published, school: school)

      visit edit_school_job_path(vacancy.id)

      verify_all_vacancy_details(VacancyPresenter.new(vacancy))
    end

    scenario 'takes you to the edit page' do
      vacancy = create(:vacancy, :published, school: school)
      visit edit_school_job_path(vacancy.id)

      expect(page).to have_content("Edit job for #{school.name}")
    end

    context '#job_specification' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content("Edit job for #{school.name}")
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_title]', with: ''
        click_on 'Update job'

        expect(page).to have_content('Job title can\'t be blank')
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on 'Update job'

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('Assistant Head Teacher')
      end

      scenario 'ensures the vacancy slug is updated when the title is saved' do
        vacancy = create(:vacancy, :published, slug: 'the-vacancy-slug', school: school)
        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on 'Update job'

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('Assistant Head Teacher')

        visit job_path(vacancy.reload)
        expect(page.current_path).to eq('/jobs/assistant-head-teacher')
      end

      scenario 'tracks the vacancy update' do
        vacancy = create(:vacancy, :published, school: school)
        job_title = vacancy.job_title

        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on 'Update job'

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(job_title: [job_title, 'Assistant Head Teacher'])
      end

      scenario 'notifies the Google index service' do
        vacancy = create(:vacancy, :published, school: school)

        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text('Job title')

        fill_in 'job_specification_form[job_description]', with: 'Sample description'
        click_on 'Update job'
      end
    end

    context '#candidate_specification' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content("Edit job for #{school.name}")
        click_link_in_container_with_text(I18n.t('jobs.experience'))

        fill_in 'candidate_specification_form[experience]', with: ''
        click_on 'Update job'

        within_row_for(text: I18n.t('jobs.experience')) do
          expect(page).to have_content('can\'t be blank')
        end
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text(I18n.t('jobs.qualifications'))

        fill_in 'candidate_specification_form[qualifications]', with: 'Teaching deegree'
        click_on 'Update job'

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('Teaching deegree')
      end

      scenario 'tracks the vacancy update' do
        vacancy = create(:vacancy, :published, school: school)
        qualifications = vacancy.qualifications

        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text(I18n.t('jobs.qualifications'))

        fill_in 'candidate_specification_form[qualifications]', with: 'Teaching deegree'
        click_on 'Update job'

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(qualifications: [qualifications,
                                                                               'Teaching deegree'])
      end

      scenario 'adds a job to update the Google index in the queue' do
        vacancy = create(:vacancy, :published, school: school)

        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text(I18n.t('jobs.qualifications'))

        fill_in 'candidate_specification_form[qualifications]', with: 'Teaching deegree'
        click_on 'Update job'
      end
    end

    context '#application_details' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content("Edit job for #{school.name}")
        click_link_in_container_with_text(I18n.t('jobs.application_link'))

        fill_in 'application_details_form[application_link]', with: 'some link'
        click_on 'Update job'

        within_row_for(text: I18n.t('jobs.application_link')) do
          expect(page).to have_content(I18n.t('errors.url.invalid'))
        end
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        vacancy = VacancyPresenter.new(vacancy)
        visit edit_school_job_path(vacancy.id)

        click_link_in_container_with_text(I18n.t('jobs.application_link'))
        vacancy.application_link = 'https://tvs.com'

        fill_in 'application_details_form[application_link]', with: vacancy.application_link
        click_on 'Update job'

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        verify_all_vacancy_details(vacancy)
      end

      context 'if the job post has already been published' do
        context 'and the publication date is in the past' do
          scenario 'renders the publication date as text and does not allow editing' do
            vacancy = build(:vacancy, :published, slug: 'test-slug', publish_on: 1.day.ago, school: school)
            vacancy.save(validate: false)
            vacancy = VacancyPresenter.new(vacancy)
            visit edit_school_job_path(vacancy.id)

            click_header_link(I18n.t('jobs.application_details'))
            expect(page).to have_content('Date role will be listed')
            expect(page).to have_content(format_date(vacancy.publish_on))
            expect(page).not_to have_css('#application_details_form_publish_on_dd')

            fill_in 'application_details_form[application_link]', with: vacancy.application_link
            click_on 'Update job'

            expect(page).to have_content(I18n.t('messages.jobs.updated'))
            verify_all_vacancy_details(vacancy)
          end
        end

        context 'and the publication date is in the future' do
          scenario 'renders the publication date as text and allows editing' do
            vacancy = create(:vacancy, :published, publish_on: Time.zone.now + 3.days, school: school)
            vacancy = VacancyPresenter.new(vacancy)
            visit edit_school_job_path(vacancy.id)
            click_link_in_container_with_text(I18n.t('jobs.publication_date'))

            expect(page).to have_content('Date role will be listed')
            expect(page).to have_css('#application_details_form_publish_on_dd')

            fill_in 'application_details_form[publish_on_dd]', with: (Time.zone.today + 2.days).day
            fill_in 'application_details_form[publish_on_mm]', with: (Time.zone.today + 2.days).month
            fill_in 'application_details_form[publish_on_yyyy]', with: (Time.zone.today + 2.days).year
            click_on 'Update job'

            expect(page).to have_content(I18n.t('messages.jobs.updated'))

            vacancy.publish_on = Time.zone.today + 2.days
            verify_all_vacancy_details(vacancy)
          end
        end
      end

      scenario 'tracks the vacancy update' do
        vacancy = create(:vacancy, :published, school: school)
        application_link = vacancy.application_link

        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text(I18n.t('jobs.application_link'))

        fill_in 'application_details_form[application_link]', with: 'https://schooljobs.com'
        click_on 'Update job'

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(application_link: [application_link,
                                                                                 'https://schooljobs.com'])
      end

      scenario 'adds a job to update the Google index in the queue' do
        vacancy = create(:vacancy, :published, school: school)

        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_school_job_path(vacancy.id)
        click_link_in_container_with_text(I18n.t('jobs.application_link'))

        fill_in 'application_details_form[application_link]', with: 'https://schooljobs.com'
        click_on 'Update job'
      end
    end
  end
end
