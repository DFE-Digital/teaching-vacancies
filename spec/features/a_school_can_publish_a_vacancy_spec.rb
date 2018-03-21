require 'rails_helper'
RSpec.feature 'A school publishing a vacancy' do
  context 'when creating a new vacancy it is' do
    let(:school) { create(:school) }

    it 'redirected to step 1, the job specification' do
      visit new_school_vacancies_path(school_id: school.id)

      expect(page).to have_content("Publish a vacancy for #{school.name}")
      expect(page).to have_content('Step 1 of 3')
    end

    it 'must fill in all the mandatory job specification fields' do
      visit new_school_vacancies_path(school_id: school.id)

      click_on 'Save and continue'
      expect(page).to have_content('error')
      expect(page).to have_content('Job title can\'t be blank')
      expect(page).to have_content('Job description can\'t be blank')
      expect(page).to have_content('Headline can\'t be blank')
      expect(page).to have_content('Minimum salary can\'t be blank')
      expect(page).to have_content('Working pattern can\'t be blank')
    end

    it 'when all mandatory fields are submitted then the school is redirected to the candidate profile' do
      visit new_school_vacancies_path(school_id: school.id)

      fill_in 'job_specification_form[job_title]', with: 'Physics teacher'
      fill_in 'job_specification_form[headline]', with: 'Physics teacher for Y5'
      fill_in 'job_specification_form[job_description]', with: 'We are looking for a teacher'
      select 'Full time', from: 'job_specification_form[working_pattern]'
      fill_in 'job_specification_form[minimum_salary]', with: 12345
      click_on 'Save and continue'

      expect(page).to have_content('Step 2 of 3')
    end

    context 'candidate profile' do
      it 'all mandatory fields must be submitted' do
        visit new_school_vacancies_path(school_id: school.id)

        fill_in 'job_specification_form[job_title]', with: 'Physics teacher'
        fill_in 'job_specification_form[headline]', with: 'Physics teacher for Y5'
        fill_in 'job_specification_form[job_description]', with: 'We are looking for a teacher'
        select 'Full time', from: 'job_specification_form[working_pattern]'
        fill_in 'job_specification_form[minimum_salary]', with: 12345
        click_on 'Save and continue'

        expect(page).to have_content('Step 2 of 3')

        click_on 'Save and continue'

        expect(page).to have_content('error')
        expect(page).to have_content('Essential requirements can\'t be blank')
      end

      it 'when the mandatory fields are submitted it redirects to the next step' do
        visit new_school_vacancies_path(school_id: school.id)
        fill_in 'job_specification_form[job_title]', with: 'Physics teacher'
        fill_in 'job_specification_form[headline]', with: 'Physics teacher for Y5'
        fill_in 'job_specification_form[job_description]', with: 'We are looking for a teacher'
        select 'Full time', from: 'job_specification_form[working_pattern]'
        fill_in 'job_specification_form[minimum_salary]', with: 12345
        click_on 'Save and continue'

        fill_in 'candidate_specification_form[essential_requirements]', with: 'Some requirements'
        click_on 'Save and continue'

        expect(page).to have_content('Step 3')
      end
    end
  end
end
