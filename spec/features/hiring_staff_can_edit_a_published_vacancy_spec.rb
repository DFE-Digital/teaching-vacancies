require 'rails_helper'
RSpec.feature 'Hiring staff can edit a vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'when attempting to edit a draft vacancy' do
    let(:vacancy) { create(:vacancy, :draft, school: school) }

    scenario 'redirects to the review vacancy page' do
      visit edit_organisation_job_path(vacancy.id)

      expect(page).to have_content(I18n.t('jobs.review_heading'))
    end
  end

  context 'when editing a published vacancy' do
    let(:vacancy) do
      VacancyPresenter.new(create(:vacancy, :complete,
                                  job_roles: [
                                    I18n.t('jobs.job_role_options.teacher'),
                                    I18n.t('jobs.job_role_options.sen_specialist')
                                   ],
                                  school: school,
                                  working_patterns: ['full_time', 'part_time'],
                                  publish_on: Time.zone.today, expires_on: Time.zone.tomorrow))
    end

    context 'when the vacancy is now invalid' do
      before do
        vacancy.about_school = nil
        vacancy.save(validate: false)
      end

      scenario 'shows action required error message' do
        visit edit_organisation_job_path(vacancy.id)

        within '#errors.govuk-notification--danger' do
          expect(page).to have_content(I18n.t('messages.jobs.action_required.heading'))
          expect(page).to have_content(I18n.t('messages.jobs.action_required.message'))
          expect(page).to have_content(I18n.t('job_summary_errors.about_school.blank'))
        end
      end
    end

    scenario 'shows all vacancy information' do
      visit edit_organisation_job_path(vacancy.id)

      verify_all_vacancy_details(vacancy)
    end

    scenario 'takes you to the edit page' do
      visit edit_organisation_job_path(vacancy.id)

      within('h1.govuk-heading-m') do
        expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
      end
    end

    scenario 'vacancy state is edit_published' do
      visit edit_organisation_job_path(vacancy.id)
      expect(Vacancy.last.state).to eql('edit_published')

      click_header_link(I18n.t('jobs.job_details'))
      expect(Vacancy.last.state).to eql('edit_published')
    end

    scenario 'create a job sidebar is not present' do
      visit edit_organisation_job_path(vacancy.id)

      expect(page).to_not have_content('Creating a job listing steps')
    end

    describe '#cancel_and_return_later' do
      scenario 'can cancel and return from job details page' do
        visit edit_organisation_job_path(vacancy.id)

        click_header_link(I18n.t('jobs.job_details'))
        expect(page).to have_content(I18n.t('buttons.cancel_and_return'))

        click_on I18n.t('buttons.cancel_and_return')
        expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      end
    end

    describe '#job_specification' do
      scenario 'can not be edited when validation fails' do
        visit edit_organisation_job_path(vacancy.id)

        within('h1.govuk-heading-m') do
          expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
        end
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: ''
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content('Enter a job title')
      end

      scenario 'can be successfully edited' do
        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')

        expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: 'Assistant Head Teacher'))
        expect(page).to have_content('Assistant Head Teacher')
      end

      scenario 'ensures the vacancy slug is updated when the title is saved' do
        vacancy = create(:vacancy, :published, slug: 'the-vacancy-slug', school: school)
        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')

        expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: 'Assistant Head Teacher'))
        expect(page).to have_content('Assistant Head Teacher')

        visit job_path(vacancy.reload)
        expect(page.current_path).to eq('/jobs/assistant-head-teacher')
      end

      scenario 'tracks the vacancy update' do
        job_title = vacancy.job_title

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(job_title: [job_title, 'Assistant Head Teacher'])
      end

      scenario 'notifies the Google index service' do
        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')
      end
    end

    describe '#pay_package' do
      scenario 'can not be edited when validation fails' do
        visit edit_organisation_job_path(vacancy.id)

        within('h1.govuk-heading-m') do
          expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
        end

        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: ''
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.salary')) do
          expect(page).to have_content(I18n.t('pay_package_errors.salary.blank'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: 'Pay scale 1 to Pay scale 2'
        click_on I18n.t('buttons.update_job')

        expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: vacancy.job_title))
        expect(page).to have_content('Pay scale 1 to Pay scale 2')
      end

      scenario 'tracks the vacancy update' do
        salary = vacancy.salary

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: 'Pay scale 1 to Pay scale 2'
        click_on I18n.t('buttons.update_job')

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(
          salary: [salary, 'Pay scale 1 to Pay scale 2']
        )
      end

      scenario 'adds a job to update the Google index in the queue' do
        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: 'Pay scale 1 to Pay scale 2'
        click_on I18n.t('buttons.update_job')
      end
    end

    describe '#important_dates' do
      def edit_date(date_type, date)
        fill_in "important_dates_form[#{date_type}(3i)]", with: date&.day.presence || ''
        fill_in "important_dates_form[#{date_type}(2i)]", with: date&.month.presence || ''
        fill_in "important_dates_form[#{date_type}(1i)]", with: date&.year.presence || ''
        click_on I18n.t('buttons.update_job')
      end

      scenario 'can not be edited when validation fails' do
        visit edit_organisation_job_path(vacancy.id)

        within('h1.govuk-heading-m') do
          expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
        end
        click_header_link(I18n.t('jobs.important_dates'))

        edit_date('expires_on', nil)

        within_row_for(element: 'legend',
                       text: strip_tags(I18n.t('helpers.fieldset.important_dates_form.expires_on_html'))) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.important_dates_form.attributes.expires_on.blank')
          )
        end
      end

      scenario 'can not be saved when expiry time validation fails' do
        visit edit_organisation_job_path(vacancy.id)

        within('h1.govuk-heading-m') do
          expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
        end
        click_header_link(I18n.t('jobs.important_dates'))

        fill_in 'important_dates_form[expiry_time_hh]', with: '88'
        click_on I18n.t('buttons.update_job')

        within_row_for(element: 'legend',
                       text: strip_tags(I18n.t('helpers.fieldset.important_dates_form.expiry_time_html'))) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.wrong_format'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.important_dates'))

        expiry_date = Time.zone.today + 1.week
        edit_date('expires_on', expiry_date)

        expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: vacancy.job_title))
        # Using String#strip to get rid of an initial space in e.g. " 1 July 2020" which caused test failures
        # due to a leading newline in the body ("\n1 July 2020").
        expect(page).to have_content(expiry_date.to_s.strip)
      end

      scenario 'tracks the vacancy update' do
        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.important_dates'))

        expiry_date = Time.zone.today + 1.week
        edit_date('expires_on', expiry_date)

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(
          expires_on: [vacancy.expires_on.to_s, expiry_date.to_s]
        )
      end

      scenario 'adds a job to update the Google index in the queue' do
        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.important_dates'))

        expiry_date = Time.zone.today + 1.week
        edit_date('expires_on', expiry_date)
      end

      context 'when the job post has already been published' do
        context 'when the publication date is in the past' do
          scenario 'renders the publication date as text and does not allow editing' do
            vacancy = build(:vacancy, :published, slug: 'test-slug', publish_on: 1.day.ago, school: school)
            vacancy.save(validate: false)
            vacancy = VacancyPresenter.new(vacancy)
            visit edit_organisation_job_path(vacancy.id)

            click_header_link(I18n.t('jobs.important_dates'))
            expect(page).to have_content(I18n.t('jobs.publication_date'))
            expect(page).to have_content(format_date(vacancy.publish_on))
            expect(page).not_to have_css('#important_dates_form_publish_on_dd')

            fill_in 'important_dates_form[expires_on(3i)]', with: vacancy.expires_on.day
            click_on I18n.t('buttons.update_job')

            expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: vacancy.job_title))
            verify_all_vacancy_details(vacancy)
          end
        end

        context 'when the publication date is in the future' do
          scenario 'renders the publication date as text and allows editing' do
            vacancy = create(:vacancy, :published, publish_on: Time.zone.now + 3.days, school: school)
            vacancy = VacancyPresenter.new(vacancy)
            visit edit_organisation_job_path(vacancy.id)
            click_header_link(I18n.t('jobs.important_dates'))

            expect(page).to have_css('#important_dates_form_publish_on_3i')

            publish_on = Time.zone.today + 1.week
            edit_date('publish_on', publish_on)

            expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: vacancy.job_title))

            vacancy.publish_on = publish_on
            verify_all_vacancy_details(vacancy)
          end
        end
      end
    end

    describe '#supporting_documents' do
      scenario 'can edit documents for a legacy vacancy' do
        vacancy.supporting_documents = nil
        vacancy.documents = []
        vacancy.save

        visit edit_organisation_job_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        expect(page).to have_content(I18n.t('messages.jobs.new_sections.message'))
        expect(page).to have_selector('.new--supporting_documents')

        click_header_link(I18n.t('jobs.supporting_documents'))

        expect(page).to have_content(I18n.t('jobs.upload_file'))

        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        expect(page).to_not have_selector('.new--supporting_documents')
        expect(page).to_not have_content(I18n.t('messages.jobs.new_sections.message'))
      end
    end

    describe '#application_details' do
      scenario 'can not be edited when validation fails' do
        visit edit_organisation_job_path(vacancy.id)

        within('h1.govuk-heading-m') do
          expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
        end
        click_header_link(I18n.t('jobs.application_details'))

        fill_in 'application_details_form[application_link]', with: 'some link'
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.application_link')) do
          expect(page).to have_content(I18n.t('application_details_errors.application_link.url'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_organisation_job_path(vacancy.id)

        click_header_link(I18n.t('jobs.application_details'))
        vacancy.application_link = 'https://tvs.com'

        fill_in 'application_details_form[application_link]', with: vacancy.application_link
        click_on I18n.t('buttons.update_job')

        expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: vacancy.job_title))

        verify_all_vacancy_details(vacancy)
      end

      scenario 'tracks the vacancy update' do
        application_link = vacancy.application_link

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.application_details'))

        fill_in 'application_details_form[application_link]', with: 'https://schooljobs.com'
        click_on I18n.t('buttons.update_job')

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(application_link: [application_link,
                                                                                 'https://schooljobs.com'])
      end

      scenario 'adds a job to update the Google index in the queue' do
        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.application_details'))

        fill_in 'application_details_form[application_link]', with: 'https://schooljobs.com'
        click_on I18n.t('buttons.update_job')
      end
    end

    describe '#job_summary' do
      scenario 'can not be edited when validation fails' do
        visit edit_organisation_job_path(vacancy.id)

        within('h1.govuk-heading-m') do
          expect(page).to have_content(I18n.t('jobs.edit_job_title', job_title: vacancy.job_title))
        end
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: ''
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.job_summary')) do
          expect(page).to have_content(I18n.t('job_summary_errors.job_summary.blank'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: 'A summary about the job.'
        click_on I18n.t('buttons.update_job')

        expect(page.body).to include(I18n.t('messages.jobs.listing_updated', job_title: vacancy.job_title))
        expect(page).to have_content('A summary about the job.')
      end

      scenario 'tracks the vacancy update' do
        job_summary = vacancy.job_summary

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: 'A summary about the job.'
        click_on I18n.t('buttons.update_job')

        activity = vacancy.activities.last
        expect(activity.key).to eq('vacancy.update')
        expect(activity.session_id).to eq(session_id)
        expect(activity.parameters.symbolize_keys).to include(
          job_summary: [strip_tags(job_summary), 'A summary about the job.']
        )
      end

      scenario 'adds a job to update the Google index in the queue' do
        expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
          .to receive(:update_google_index).with(vacancy)

        visit edit_organisation_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: 'A summary about the job.'
        click_on I18n.t('buttons.update_job')
      end
    end
  end
end
