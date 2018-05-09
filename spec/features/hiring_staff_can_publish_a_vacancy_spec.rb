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

    visit school_path(school)

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
                                 subject: subjects.sample,
                                 leadership: leaderships.sample))
    end

    scenario 'redirects to step 1, job specification' do
      visit new_school_job_path(school)

      expect(page.current_path).to eq(job_specification_school_job_path(school))
      expect(page).to have_content("Publish a job for #{school.name}")
      expect(page).to have_content('Step 1 of 3')
    end

    context '#job_specification' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path(school)

        click_on 'Save and continue'

        within('.error-summary') do
          expect(page).to have_content('4 errors prevented this job from being saved:')
        end

        within_row_for(text: I18n.t('jobs.job_title')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_title.blank'))
        end

        within_row_for(text: I18n.t('jobs.description')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_description.blank'))
        end

        within_row_for(text: I18n.t('jobs.salary_range')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.blank'))
        end

        within_row_for(text: I18n.t('jobs.working_pattern')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.working_pattern.blank'))
        end
      end

      scenario 'redirects to step 2, candidate profile, when submitted succesfuly' do
        visit new_school_job_path(school)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 2 of 3')
      end

      scenario 'tracks the vacancy creation' do
        visit new_school_job_path(school)

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
        visit new_school_job_path(school)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        click_on 'Save and continue' # submit empty form

        within('.error-summary') do
          expect(page).to have_content('3 errors prevented this job from being saved:')
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
        visit new_school_job_path(school)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 3 of 3')
      end
    end

    context '#application_details' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path(school)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Save and continue'

        within('.error-summary') do
          expect(page).to have_content('4 errors prevented this job from being saved:')
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
        visit new_school_job_path(school)

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
      scenario 'is not available for published vacancies' do
        vacancy = create(:vacancy, :published, school_id: school.id)

        visit school_job_review_path(school, vacancy.id)

        expect(page).to have_current_path(school_job_path(school, vacancy.id))
      end

      scenario 'lists all the vacancy details correctly' do
        vacancy = VacancyPresenter.new(create(:vacancy, :complete, :draft, school_id: school.id))
        visit school_job_review_path(school, vacancy.id)

        expect(page).to have_content("Review the job for #{school.name}")

        verify_all_vacancy_details(vacancy)
      end

      context 'edit job_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(school, vacancy.id)
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
          visit school_job_review_path(school, vacancy.id)
          click_link_in_container_with_text('Job title')

          expect(page).to have_content('Step 1 of 3')

          fill_in 'job_specification_form[job_title]', with: 'High school teacher'
          click_on 'Save and continue'

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to eq(job_title: [current_title, 'High school teacher'])
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(school, vacancy.id)
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
          visit school_job_review_path(school, vacancy.id)
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
          visit school_job_review_path(school, vacancy.id)
          click_link_in_container_with_text('Essential qualifications')

          fill_in 'candidate_specification_form[qualifications]', with: 'Teaching diploma'
          click_on 'Save and continue'

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to eq(qualifications: [qualifications, 'Teaching diploma'])
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(school, vacancy.id)
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
          visit school_job_review_path(school, vacancy.id)
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

        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(school, vacancy.id)
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
          visit school_job_review_path(school, vacancy.id)
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
        visit school_job_review_path(school, vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content('The job has been posted, you can view it here:')
      end
    end

    context '#publish' do
      scenario 'can not be published unless the details are valid' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)
        vacancy.assign_attributes qualifications: nil
        vacancy.save(validate: false)

        visit school_job_review_path(school, vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content(I18n.t('errors.jobs.unable_to_publish'))
      end

      scenario 'can be published at a later date' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(school, vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content("The job will be posted on #{vacancy.publish_on}, you can preview it here:")
        visit job_url(vacancy)
        expect(page).to have_content("Date posted #{format_date(vacancy.publish_on)}")
      end

      scenario 'tracks publishing information' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(school, vacancy.id)
        click_on 'Confirm and submit job'

        activity = vacancy.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.publish')
      end

      scenario 'a published vacancy cannot be edited' do
        visit new_school_job_path(school)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Confirm and submit job'
        expect(page).to have_content('The job has been posted, you can view it here:')

        visit candidate_specification_school_job_path(school)
        expect(page.current_path).to eq(job_specification_school_job_path(school))

        visit application_details_school_job_path(school)
        expect(page.current_path).to eq(job_specification_school_job_path(school))
      end
    end
  end
end
