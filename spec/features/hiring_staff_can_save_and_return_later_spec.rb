require 'rails_helper'


RSpec.feature 'Hiring staff can save and return later' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
    @vacancy = VacancyPresenter.new(build(:vacancy, :draft))
  end

  context 'Create a job journey' do
    context '#job_details' do
      scenario 'can save and return later' do
        visit school_path
        click_on I18n.t('buttons.create_job')

        expect(page.current_path).to eql(job_specification_school_job_path)
        expect(page).to have_content(I18n.t('jobs.create_a_job', school: school.name))
        expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 6))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_details'))
        end

        fill_in 'job_specification_form[job_title]', with: @vacancy.job_title
        click_on I18n.t('buttons.save_and_return_later')
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        expect(page.current_path).to eql(jobs_with_type_school_path('draft'))
        expect(page.body).to include(I18n.t('messages.jobs.draft_saved_html', job_title: @vacancy.job_title))

        click_on 'Edit'

        expect(page.current_path).to eql(school_job_job_specification_path(created_vacancy.id))
        expect(find_field('job_specification_form[job_title]').value).to eql(@vacancy.job_title)
      end
    end

    context '#pay_package' do
      scenario 'can save and return later' do
        visit school_path
        click_on I18n.t('buttons.create_job')

        fill_in_job_specification_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        expect(page.current_path).to eql(school_job_pay_package_path(created_vacancy.id))

        fill_in 'pay_package_form[benefits]', with: @vacancy.benefits
        click_on I18n.t('buttons.save_and_return_later')

        expect(page.current_path).to eql(jobs_with_type_school_path('draft'))
        expect(page.body).to include(I18n.t('messages.jobs.draft_saved_html', job_title: @vacancy.job_title))

        click_on 'Edit'

        expect(page.current_path).to eql(school_job_pay_package_path(created_vacancy.id))
        expect(find_field('pay_package_form[benefits]').value).to eql(@vacancy.benefits)
      end
    end

    context '#supporting_documents' do
      scenario 'can save and return later' do
        visit school_path
        click_on I18n.t('buttons.create_job')

        fill_in_job_specification_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')

        expect(page.current_path).to eql(school_job_supporting_documents_path(created_vacancy.id))

        click_on I18n.t('buttons.save_and_return_later')

        expect(page.current_path).to eql(jobs_with_type_school_path('draft'))
        expect(page.body).to include(I18n.t('messages.jobs.draft_saved_html', job_title: @vacancy.job_title))

        click_on 'Edit'

        expect(page.current_path).to eql(school_job_supporting_documents_path(created_vacancy.id))
        expect(find_field('supporting-documents-form-supporting-documents-yes-field').checked?).to eql(false)
        expect(find_field('supporting-documents-form-supporting-documents-no-field').checked?).to eql(false)
      end
    end

    context '#application_details' do
      scenario 'can save and return later' do
        visit school_path
        click_on I18n.t('buttons.create_job')

        fill_in_job_specification_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.save_and_continue')

        expect(page.current_path).to eql(school_job_application_details_path(created_vacancy.id))

        yesterday = 1.day.ago
        fill_in 'application_details_form[expires_on(3i)]', with: yesterday.day
        fill_in 'application_details_form[expires_on(2i)]', with: yesterday.month
        fill_in 'application_details_form[expires_on(1i)]', with: yesterday.year
        click_on I18n.t('buttons.save_and_return_later')

        expect(page.current_path).to eql(jobs_with_type_school_path('draft'))
        expect(page.body).to include(I18n.t('messages.jobs.draft_saved_html', job_title: @vacancy.job_title))

        click_on 'Edit'

        expect(page.current_path).to eql(school_job_application_details_path(created_vacancy.id))
        expect(find_field('application_details_form[expires_on(3i)]').value).to eql(yesterday.day.to_s)
        expect(find_field('application_details_form[expires_on(2i)]').value).to eql(yesterday.month.to_s)
        expect(find_field('application_details_form[expires_on(1i)]').value).to eql(yesterday.year.to_s)
      end
    end

    context '#job_summary' do
      scenario 'can save and return later' do
        visit school_path
        click_on I18n.t('buttons.create_job')

        fill_in_job_specification_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')
        created_vacancy = Vacancy.find_by(job_title: @vacancy.job_title)

        fill_in_pay_package_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.save_and_continue')

        fill_in_application_details_form_fields(@vacancy)
        click_on I18n.t('buttons.save_and_continue')

        expect(page.current_path).to eql(school_job_job_summary_path(created_vacancy.id))

        fill_in 'job_summary_form[job_summary]', with: ''
        fill_in 'job_summary_form[about_school]', with: @vacancy.about_school
        click_on I18n.t('buttons.save_and_return_later')

        expect(page.current_path).to eql(jobs_with_type_school_path('draft'))
        expect(page.body).to include(I18n.t('messages.jobs.draft_saved_html', job_title: @vacancy.job_title))

        click_on 'Edit'

        expect(page.current_path).to eql(school_job_job_summary_path(created_vacancy.id))
        expect(find_field('job_summary_form[job_summary]').value).to eql('')
        expect(find_field('job_summary_form[about_school]').value).to eql(@vacancy.about_school)
      end
    end
  end
end
