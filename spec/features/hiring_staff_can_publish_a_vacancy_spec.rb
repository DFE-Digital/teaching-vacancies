require 'rails_helper'
RSpec.feature 'Creating a vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  scenario 'Visiting the school page' do
    school = create(:school, name: 'Salisbury School')
    stub_hiring_staff_auth(urn: school.urn)

    visit school_path

    expect(page).to have_content('Salisbury School')
    expect(page).to have_content(/#{school.address}/)
    expect(page).to have_content(/#{school.town}/)

    click_link 'Create a job'

    expect(page).to have_content('Step 1 of 3')
  end

  context 'creating a new vacancy' do
    let!(:pay_scales) { create_list(:pay_scale, 3) }
    let!(:subjects) { create_list(:subject, 3) }
    let!(:leaderships) { create_list(:leadership, 3) }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy, :complete,
                                 min_pay_scale: pay_scales.sample,
                                 max_pay_scale: pay_scales.sample,
                                 subject: subjects[0],
                                 first_supporting_subject: subjects[1],
                                 second_supporting_subject: subjects[2],
                                 leadership: leaderships.sample))
    end

    scenario 'redirects to step 1, job specification' do
      visit new_school_job_path

      expect(page.current_path).to eq(job_specification_school_job_path)
      expect(page).to have_content("Publish a job for #{school.name}")
      expect(page).to have_content('Step 1 of 3')
    end

    context '#job_specification' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        click_on 'Save and continue'

        within('.govuk-error-summary') do
          expect(page).to have_content('Please correct the following 4 errors in your listing:')
        end

        within_row_for(text: I18n.t('jobs.job_title')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_title.blank'))
        end

        within_row_for(text: I18n.t('jobs.description')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_description.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('jobs.salary_range')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.blank'))
        end

        within_row_for(text: I18n.t('jobs.working_pattern')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.working_pattern.blank'))
        end
      end

      scenario 'redirects to step 2, candidate profile, when submitted succesfuly' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 2 of 3')
      end

      scenario 'tracks the vacancy creation' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        activity = Vacancy.last.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.create')
        expect(activity.parameters.symbolize_keys).to include(job_title: [nil, vacancy.job_title])
      end
    end

    context '#candidate_profile' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        click_on 'Save and continue' # submit empty form

        within('.govuk-error-summary') do
          expect(page).to have_content('Please correct the following 3 errors in your listing:')
        end

        within_row_for(text: I18n.t('jobs.education')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.education.blank'))
        end

        within_row_for(text: I18n.t('jobs.qualifications')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.qualifications.blank'))
        end
        within_row_for(text: I18n.t('jobs.experience')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.experience.blank'))
        end
      end

      scenario 'redirects to step 3, application_details profile, when submitted succesfuly' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 3 of 3')
      end
    end

    context '#application_details' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Save and continue'

        within('.govuk-error-summary') do
          expect(page).to have_content('Please correct the following 4 errors in your listing:')
        end

        within_row_for(text: I18n.t('jobs.contact_email')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.contact_email.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('jobs.deadline_date')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('jobs.publication_date')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.blank'))
        end
      end

      scenario 'redirects to the vacancy review page when submitted succesfuly' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content(I18n.t('jobs.review'))
        verify_all_vacancy_details(vacancy)
      end
    end

    context '#review' do
      context 'redirects the user back to the last incomplete step' do
        scenario 'redirects to step 2, candidate profile, when that step has not been completed' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on 'Save and continue'

          visit school_path
          click_on vacancy.job_title

          expect(page).to have_content('Step 2 of 3')
        end

        scenario 'redirects to step 3, application details, when that step has not been completed' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on 'Save and continue'

          fill_in_candidate_specification_form_fields(vacancy)
          click_on 'Save and continue'

          visit school_path
          click_on vacancy.job_title

          expect(page).to have_content('Step 3 of 3')
        end
      end

      scenario 'is not available for published vacancies' do
        vacancy = create(:vacancy, :published, school_id: school.id)

        visit school_job_review_path(vacancy.id)

        expect(page).to have_current_path(school_job_path(vacancy.id))
      end

      scenario 'lists all the vacancy details correctly' do
        vacancy = VacancyPresenter.new(create(:vacancy, :complete, :draft, school_id: school.id))
        visit school_job_review_path(vacancy.id)

        expect(page).to have_content("Review the job for #{school.name}")

        verify_all_vacancy_details(vacancy)
      end

      scenario 'enables the user to resolve cross-form errors' do
        vacancy = build(:vacancy, :draft, :complete, slug: 'vacancy-slug', school_id: school.id,
                                                     starts_on: Time.zone.today)
        vacancy.save(validate: false)

        visit school_job_review_path(vacancy.id)
        expect(page)
          .to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on'))

        click_link_in_container_with_text(I18n.t('jobs.starts_on'))
        expect(page)
          .to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on'))
      end

      context 'when the listing is full-time' do
        scenario 'lists all the full-time vacancy details correctly' do
          vacancy = VacancyPresenter.new(
            create(:vacancy,
                   :complete,
                   :draft,
                   school_id: school.id,
                   working_pattern: :full_time)
          )
          visit school_job_review_path(vacancy.id)

          expect(page).to have_content("Review the job for #{school.name}")

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'when the listing is part-time' do
        scenario 'lists all the part-time vacancy details correctly' do
          vacancy = VacancyPresenter.new(
            create(:vacancy,
                   :complete,
                   :draft,
                   school_id: school.id,
                   working_pattern: :part_time)
          )
          visit school_job_review_path(vacancy.id)

          expect(page).to have_content("Review the job for #{school.name}")

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'edit job_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Job title')

          expect(page).to have_content('Step 1 of 3')

          fill_in 'job_specification_form[job_title]', with: 'An edited job title'
          click_on 'Save and continue'

          expect(page).to have_content("Review the job for #{school.name}")
          expect(page).to have_content('An edited job title')
        end

        scenario 'tracks any changes to  the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          current_title = vacancy.job_title
          current_slug = vacancy.slug
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Job title')

          expect(page).to have_content('Step 1 of 3')

          fill_in 'job_specification_form[job_title]', with: 'High school teacher'
          click_on 'Save and continue'

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to include(job_title: [current_title, 'High school teacher'])
          expect(activity.parameters.symbolize_keys).to include(slug: [current_slug, 'high-school-teacher'])
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Job title')

          fill_in 'job_specification_form[job_title]', with: ''
          click_on 'Save and continue'

          expect(page).to have_content('Job title can\'t be blank')

          fill_in 'job_specification_form[job_title]', with: 'A new job title'
          click_on 'Save and continue'

          expect(page).to have_content("Review the job for #{school.name}")
          expect(page).to have_content('A new job title')
        end
      end

      context 'editing the candidate_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Essential qualifications')

          expect(page).to have_content('Step 2 of 3')

          fill_in 'candidate_specification_form[qualifications]', with: 'Teaching diploma'
          click_on 'Save and continue'

          expect(page).to have_content("Review the job for #{school.name}")
          expect(page).to have_content('Teaching diploma')
        end

        scenario 'tracks any changes to  the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          qualifications = vacancy.qualifications
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Essential qualifications')

          fill_in 'candidate_specification_form[qualifications]', with: 'Teaching diploma'
          click_on 'Save and continue'

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to eq(qualifications: [qualifications, 'Teaching diploma'])
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Essential educational requirements')

          expect(page).to have_content('Step 2 of 3')

          fill_in 'candidate_specification_form[education]', with: ''
          click_on 'Save and continue'

          expect(page).to have_content('Education can\'t be blank')

          fill_in 'candidate_specification_form[education]', with: 'essential requirements'
          click_on 'Save and continue'

          expect(page).to have_content('Confirm and submit job')
          expect(page).to have_content('essential requirements')
        end
      end

      context 'editing the application_details' do
        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Job contact email')

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[contact_email]', with: 'not a valid email'
          click_on 'Save and continue'

          expect(page).to have_content('Contact email is invalid')

          fill_in 'application_details_form[contact_email]', with: 'a@valid.email'
          click_on 'Save and continue'

          expect(page).to have_content("Review the job for #{school.name}")
          expect(page).to have_content('a@valid.email')
        end

        scenario 'fails validation correctly when an invalid link is entered' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Link for more information')

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[application_link]', with: 'www invalid.domain.com'
          click_on 'Save and continue'

          expect(page).to have_content('Application link is not a valid URL')

          fill_in 'application_details_form[application_link]', with: 'www.valid-domain.com'
          click_on 'Save and continue'

          expect(page).to have_content("Review the job for #{school.name}")
          expect(page).to have_content('www.valid-domain.com')
        end

        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Job contact email')

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on 'Save and continue'

          expect(page).to have_content("Review the job for #{school.name}")
          expect(page).to have_content('an@email.com')
        end

        scenario 'tracks any changes' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          contact_email = vacancy.contact_email
          visit school_job_review_path(vacancy.id)
          click_link_in_container_with_text('Job contact email')

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on 'Save and continue'

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to eq(contact_email: [contact_email, 'an@email.com'])
        end
      end

      scenario 'redirects to the school vacancy page when published' do
        vacancy = create(:vacancy, :draft, school_id: school.id)
        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content('Preview your job listing')
      end
    end

    context '#publish' do
      scenario 'view the published listing as a job seeker' do
        vacancy = create(:vacancy, :draft, school_id: school.id)

        visit school_job_review_path(vacancy.id)

        click_on 'Confirm and submit job'
        save_page

        click_on I18n.t('jobs.confirmation_page.preview_posted_job')

        verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
      end

      context 'when the listing is full-time' do
        scenario 'view the full-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, school_id: school.id, working_pattern: :full_time)

          visit school_job_review_path(vacancy.id)

          click_on 'Confirm and submit job'
          save_page

          click_on I18n.t('jobs.confirmation_page.preview_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      context 'when the listing is part-time' do
        scenario 'view the part-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, school_id: school.id, working_pattern: :part_time)

          visit school_job_review_path(vacancy.id)

          click_on 'Confirm and submit job'
          save_page

          click_on I18n.t('jobs.confirmation_page.preview_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      scenario 'cannot be published unless the details are valid' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)
        vacancy.assign_attributes expires_on: Time.zone.yesterday
        vacancy.save(validate: false)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content(I18n.t('errors.jobs.unable_to_publish'))
        expect(page).to have_content(
          I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date')
        )
      end

      scenario 'can be published at a later date' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content("Your job listing will be posted on #{format_date(vacancy.publish_on)}.")
        visit school_job_path(vacancy.id)
        expect(page).to have_content("Date posted #{format_date(vacancy.publish_on)}")
      end

      scenario 'can not be published at a date in the past' do
        vacancy = create(:vacancy, :draft, school_id: school.id)
        vacancy.assign_attributes(publish_on: Time.zone.yesterday)
        vacancy.save(validate: false)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content(I18n.t('errors.jobs.unable_to_publish'))
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today'))
      end

      scenario 'displays the expiration date on the confirmation page' do
        vacancy = create(:vacancy, :draft, school_id: school.id)
        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content(
          "The listing will appear on the service until #{format_date(vacancy.expires_on)}, " \
          'after which it will no longer be visible to jobseekers.'
        )
      end

      scenario 'tracks publishing information' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        activity = vacancy.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.publish')
      end

      scenario 'a published vacancy cannot be republished' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'
        expect(page).to have_content('The job listing has been completed')

        visit school_job_publish_path(vacancy.id)

        expect(page).to have_content('This job has already been published')
      end

      scenario 'a published vacancy cannot be edited' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Confirm and submit job'
        expect(page).to have_content('Preview your job listing')

        visit candidate_specification_school_job_path
        expect(page.current_path).to eq(job_specification_school_job_path)

        visit application_details_school_job_path
        expect(page.current_path).to eq(job_specification_school_job_path)
      end

      context 'adds a job to update the Google index in the queue' do
        scenario 'if the vacancy is published immediately' do
          vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.today)
          vacancy_url = job_url(vacancy, protocol: 'https')

          expect(UpdateGoogleIndexQueueJob).to receive(:perform_later).with(vacancy_url)

          visit school_job_review_path(vacancy.id)
          click_on 'Confirm and submit job'
        end
      end

      context 'updates the published vacancy spreadsheet via Sidekiq' do
        scenario 'when the vacancy is published' do
          vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.today)

          expect(UpdateVacancySpreadsheetJob).to receive(:perform_later).with(vacancy.id)

          visit school_job_review_path(vacancy.id)
          click_on 'Confirm and submit job'
        end
      end
    end
  end
end
