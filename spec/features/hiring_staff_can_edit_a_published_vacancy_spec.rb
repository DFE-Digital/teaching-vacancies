require 'rails_helper'
RSpec.feature 'Hiring staff can edit a vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  context 'attempting to edit a draft vacancy' do
    let(:vacancy) { create(:vacancy, :draft, school: school) }

    scenario 'redirects to the review vacancy page' do
      visit edit_school_job_path(vacancy.id)

      expect(page).to have_content(I18n.t('jobs.review_heading'))
    end
  end

  context 'editing a published vacancy' do
    let(:vacancy) do
      VacancyPresenter.new(create(:vacancy, :complete,
                                  job_roles: [
                                    I18n.t('jobs.job_role_options.teacher'),
                                    I18n.t('jobs.job_role_options.sen_specialist')
                                   ],
                                  school: school,
                                  subject: build(:subject),
                                  working_patterns: ['full_time', 'part_time'],
                                  publish_on: Time.zone.today))
    end

    scenario 'shows all vacancy information' do
      visit edit_school_job_path(vacancy.id)

      verify_all_vacancy_details(vacancy)
    end

    scenario 'takes you to the edit page' do
      visit edit_school_job_path(vacancy.id)

      expect(page).to have_content(I18n.t('jobs.edit_heading', school: school.name))
    end

    context '#job_specification' do
      scenario 'can not be edited when validation fails' do
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.edit_heading', school: school.name))
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: ''
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content('Enter a job title')
      end

      scenario 'can be successfully edited' do
        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('Assistant Head Teacher')
      end

      scenario 'can edit job role for a legacy vacancy' do
        # rubocop:disable Rails/SkipsModelValidations
        vacancy.update_columns(job_roles: [])
        # rubocop:enable Rails/SkipsModelValidations

        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.job_details'))
        expect(page).to have_content(I18n.t('messages.jobs.new_sections.message'))
        expect(page.find('h2', text: I18n.t('jobs.job_details'))
          .text).to include(I18n.t('jobs.notification_labels.new'))

        click_header_link(I18n.t('jobs.job_details'))

        fill_in_job_specification_form_fields(vacancy)

        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('jobs.job_details'))
        expect(page.find('h2', text: I18n.t('jobs.job_details'))
          .text).to_not include(I18n.t('jobs.notification_labels.new'))
        expect(page).to_not have_content(I18n.t('messages.jobs.new_sections.message'))
      end

      scenario 'ensures the vacancy slug is updated when the title is saved' do
        vacancy = create(:vacancy, :published, slug: 'the-vacancy-slug', school: school)
        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('Assistant Head Teacher')

        visit job_path(vacancy.reload)
        expect(page.current_path).to eq('/jobs/assistant-head-teacher')
      end

      scenario 'tracks the vacancy update' do
        job_title = vacancy.job_title

        visit edit_school_job_path(vacancy.id)
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

        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_details'))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on I18n.t('buttons.update_job')
      end
    end

    context '#pay_package' do
      scenario 'can not be edited when validation fails' do
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content("Edit job for #{school.name}")
        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: ''
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.salary')) do
          expect(page).to have_content(I18n.t('pay_package_errors.salary.blank'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: 'Pay scale 1 to Pay scale 2'
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('Pay scale 1 to Pay scale 2')
      end

      scenario 'tracks the vacancy update' do
        salary = vacancy.salary

        visit edit_school_job_path(vacancy.id)
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

        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.pay_package'))

        fill_in 'pay_package_form[salary]', with: 'Pay scale 1 to Pay scale 2'
        click_on I18n.t('buttons.update_job')
      end
    end

    context '#supporting_documents' do
      scenario 'can edit documents for a legacy vacancy' do
        vacancy.supporting_documents = nil
        vacancy.documents = []
        vacancy.save

        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        expect(page).to have_content(I18n.t('messages.jobs.new_sections.message'))
        expect(page.find('h2', text: I18n.t('jobs.supporting_documents'))
          .text).to include(I18n.t('jobs.notification_labels.new'))

        click_header_link(I18n.t('jobs.supporting_documents'))

        expect(page).to have_content(I18n.t('jobs.upload_file'))

        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        expect(page.find('h2', text: I18n.t('jobs.supporting_documents'))
          .text).to_not include(I18n.t('jobs.notification_labels.new'))
        expect(page).to_not have_content(I18n.t('messages.jobs.new_sections.message'))
      end
    end

    context '#application_details' do
      scenario 'can not be edited when validation fails' do
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content("Edit job for #{school.name}")
        click_header_link(I18n.t('jobs.application_details'))

        fill_in 'application_details_form[application_link]', with: 'some link'
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.application_link')) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.application_details_form.attributes.application_link.url'))
        end
      end

      scenario 'can not be saved when expiry time validation fails' do
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content("Edit job for #{school.name}")
        click_header_link(I18n.t('jobs.application_details'))

        fill_in 'application_details_form[expiry_time_hh]', with: '88'
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.application_link')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.wrong_format'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_school_job_path(vacancy.id)

        click_header_link(I18n.t('jobs.application_details'))
        vacancy.application_link = 'https://tvs.com'

        fill_in 'application_details_form[application_link]', with: vacancy.application_link
        click_on I18n.t('buttons.update_job')

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
            click_on I18n.t('buttons.update_job')

            expect(page).to have_content(I18n.t('messages.jobs.updated'))
            verify_all_vacancy_details(vacancy)
          end
        end

        context 'and the publication date is in the future' do
          scenario 'renders the publication date as text and allows editing' do
            vacancy = create(:vacancy, :published, publish_on: Time.zone.now + 3.days, school: school)
            vacancy = VacancyPresenter.new(vacancy)
            visit edit_school_job_path(vacancy.id)
            click_header_link(I18n.t('jobs.application_details'))

            expect(page).to have_content('Date role will be listed')
            expect(page).to have_css('#application_details_form_publish_on_3i')

            fill_in 'application_details_form[publish_on(3i)]', with: (Time.zone.today + 2.days).day
            fill_in 'application_details_form[publish_on(2i)]', with: (Time.zone.today + 2.days).month
            fill_in 'application_details_form[publish_on(1i)]', with: (Time.zone.today + 2.days).year
            click_on I18n.t('buttons.update_job')

            expect(page).to have_content(I18n.t('messages.jobs.updated'))

            vacancy.publish_on = Time.zone.today + 2.days
            verify_all_vacancy_details(vacancy)
          end
        end
      end

      scenario 'tracks the vacancy update' do
        application_link = vacancy.application_link

        visit edit_school_job_path(vacancy.id)
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

        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.application_details'))

        fill_in 'application_details_form[application_link]', with: 'https://schooljobs.com'
        click_on I18n.t('buttons.update_job')
      end
    end

    context '#job_summary' do
      scenario 'can not be edited when validation fails' do
        visit edit_school_job_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.edit_heading', school: school.name))
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: ''
        click_on I18n.t('buttons.update_job')

        within_row_for(text: I18n.t('jobs.job_summary')) do
          expect(page).to have_content(I18n.t('job_summary_errors.job_summary.blank'))
        end
      end

      scenario 'can be successfully edited' do
        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: 'A summary about the job.'
        click_on I18n.t('buttons.update_job')

        expect(page).to have_content(I18n.t('messages.jobs.updated'))
        expect(page).to have_content('A summary about the job.')
      end

      scenario 'tracks the vacancy update' do
        job_summary = vacancy.job_summary

        visit edit_school_job_path(vacancy.id)
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

        visit edit_school_job_path(vacancy.id)
        click_header_link(I18n.t('jobs.job_summary'))

        fill_in 'job_summary_form[job_summary]', with: 'A summary about the job.'
        click_on I18n.t('buttons.update_job')
      end
    end
  end
end
