require 'rails_helper'
RSpec.feature 'A school publishing a vacancy' do
  let!(:pay_scales) { create_list(:pay_scale, 3) }
  let!(:subjects) { create_list(:subject, 3) }
  let!(:leaderships) { create_list(:leadership, 3) }
  let(:school) { create(:school) }
  let(:vacancy) do
    VacancyPresenter.new(build(:vacancy, :complete,
                               pay_scale: pay_scales.sample,
                               subject: subjects.sample,
                               leadership: leaderships.sample))
  end

  context 'creating a new vacancy' do
    scenario 'redirects to step 1, job specification' do
      visit new_school_vacancy_path(school_id: school.id)

      expect(page).to have_content("Publish a vacancy for #{school.name}")
      expect(page).to have_content('Step 1 of 3')
    end

    context '#job_specification' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_vacancy_path(school_id: school.id)

        click_on 'Save and continue'
        expect(page).to have_content('Job title can\'t be blank')
        expect(page).to have_content('Job description can\'t be blank')
        expect(page).to have_content('Headline can\'t be blank')
        expect(page).to have_content('Minimum salary can\'t be blank')
        expect(page).to have_content('Working pattern can\'t be blank')
      end

      scenario 'redirects to step 2, candidate profile, when submitted succesfuly' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 2 of 3')
      end
    end

    context '#candidate_profile' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue' # step 1
        click_on 'Save and continue' # step 2

        expect(page).to have_content('error')
        expect(page).to have_content('Essential requirements can\'t be blank')
      end

      scenario 'redirects to step 3, application_details profile, when submitted succesfuly' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 3 of 3')
      end
    end

    context '#application_details' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Save and continue'

        expect(page).to have_content('Contact email can\'t be blank')
        expect(page).to have_content('Publish on can\'t be blank')
        expect(page).to have_content('Expires on can\'t be blank')
      end

      scenario 'redirects to the vacancy review page when submitted succesfuly' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to_not have_content('Step 3 of 3')
        expect(page).to have_content("Review the vacancy for #{school.name}")
      end
    end

    context '#review' do
      scenario 'lists all the vacancy details correctly' do
        vacancy = VacancyPresenter.new(create(:vacancy, :draft, school_id: school.id))
        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)

        expect(page).to have_content("Review the vacancy for #{school.name}")

        verify_all_vacancy_details(vacancy)
      end

      context 'edit job_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Job title")]]').find('a').click

          expect(page).to have_content('Step 1 of 3')

          fill_in 'job_specification_form[job_title]', with: 'An edited job title'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('An edited job title')
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Job title")]]').find('a').click

          fill_in 'job_specification_form[job_title]', with: ''
          click_on 'Save and continue'

          expect(page).to have_content('Job title can\'t be blank')

          fill_in 'job_specification_form[job_title]', with: 'A new job title'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('A new job title')
        end
      end

      context 'editing the candidate_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Qualifications")]]').find('a').click

          expect(page).to have_content('Step 2 of 3')

          fill_in 'candidate_specification_form[qualifications]', with: 'Teaching diploma'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('Teaching diploma')
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Essential requirements")]]').find('a').click

          expect(page).to have_content('Step 2 of 3')

          fill_in 'candidate_specification_form[essential_requirements]', with: ''
          click_on 'Save and continue'

          expect(page).to have_content('Essential requirements can\'t be blank')

          fill_in 'candidate_specification_form[essential_requirements]', with: 'essential requirements'
          click_on 'Save and continue'

          expect(page).to have_content('Confirm and submit vacancy')
          expect(page).to have_content('essential requirements')
        end
      end

      context 'editing the application_details' do
        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Vacancy contact email")]]').find('a').click

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[contact_email]', with: 'not a valid email'
          click_on 'Save and continue'

          expect(page).to have_content('Contact email is invalid')

          fill_in 'application_details_form[contact_email]', with: 'a@valid.email'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('a@valid.email')
        end

        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
          find(:xpath, '//div[dt[contains(text(), "Vacancy contact email")]]').find('a').click

          expect(page).to have_content('Step 3 of 3')

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on 'Save and continue'

          expect(page).to have_content("Review the vacancy for #{school.name}")
          expect(page).to have_content('an@email.com')
        end
      end

      scenario 'redirects to the school vacancy page when published' do
        vacancy = create(:vacancy, :draft, school_id: school.id)
        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
        click_on 'Confirm and submit vacancy'

        expect(page).to have_content("The system reference number is #{vacancy.reference}")
        expect(page).to have_content('The vacancy has been posted, you can view it here:')
      end
    end

    context '#publish' do
      scenario 'can be published at a later date' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)
        click_on 'Confirm and submit vacancy'

        expect(page).to have_content("The system reference number is #{vacancy.reference}")
        expect(page).to have_content("The vacancy will be posted on #{vacancy.publish_on}, you can preview it here:")
      end

      scenario 'a published vacancy cannot be edited' do
        visit new_school_vacancy_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Confirm and submit vacancy'

        visit candidate_specification_school_vacancy_path(school_id: school.id)
        expect(page.current_path).to eq(job_specification_school_vacancy_path(school_id: school.id))

        visit application_details_school_vacancy_path(school_id: school.id)
        expect(page.current_path).to eq(job_specification_school_vacancy_path(school_id: school.id))
      end
    end
  end
end
