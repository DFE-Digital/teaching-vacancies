require 'rails_helper'
RSpec.feature 'A school publishing a vacancy' do
  context 'when creating a new vacancy it is' do
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


    it 'redirected to step 1, the job specification' do
      visit new_school_vacancies_path(school_id: school.id)

      expect(page).to have_content("Publish a vacancy for #{school.name}")
      expect(page).to have_content('Step 1 of 3')
    end

    it 'must fill in all the mandatory job specification fields' do
      visit new_school_vacancies_path(school_id: school.id)

      click_on 'Save and continue'
      expect(page).to have_content('Job title can\'t be blank')
      expect(page).to have_content('Job description can\'t be blank')
      expect(page).to have_content('Headline can\'t be blank')
      expect(page).to have_content('Minimum salary can\'t be blank')
      expect(page).to have_content('Working pattern can\'t be blank')
    end

    it 'when all mandatory fields are submitted then the school is redirected to the candidate profile' do
      visit new_school_vacancies_path(school_id: school.id)

      fill_in_job_specification_form_fields(vacancy)
      click_on 'Save and continue'

      expect(page).to have_content('Step 2 of 3')
    end

    context 'candidate profile' do
      it 'all mandatory fields must be submitted' do
        visit new_school_vacancies_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue' # step 1
        click_on 'Save and continue' # step 2

        expect(page).to have_content('error')
        expect(page).to have_content('Essential requirements can\'t be blank')
      end

      it 'when the mandatory fields are submitted it redirects to the next step' do
        visit new_school_vacancies_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to have_content('Step 3 of 3')
      end
    end

    context 'application details' do
      it 'all mandatory fields must be submitted' do
        visit new_school_vacancies_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        click_on 'Save and continue'

        expect(page).to have_content('Contact email can\'t be blank')
        expect(page).to have_content('Publish on can\'t be blank')
        expect(page).to have_content('Expires on can\'t be blank')
      end

      it 'when all mandatory fields are submitted it redirects to the review page' do
        visit new_school_vacancies_path(school_id: school.id)

        fill_in_job_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_candidate_specification_form_fields(vacancy)
        click_on 'Save and continue'
        fill_in_application_details_form_fields(vacancy)
        click_on 'Save and continue'

        expect(page).to_not have_content('Step 3 of 3')
        expect(page).to have_content("Publish a vacancy for #{school.name}")

        verify_all_vacancy_details(vacancy)
      end
    end

    context 'reviewing a vacancy' do
      it 'a published vacancy cannot be edited' do
        visit new_school_vacancies_path(school_id: school.id)

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
