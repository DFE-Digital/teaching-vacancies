require 'rails_helper'
RSpec.feature 'Hiring staff can edit a vacancy' do
  let(:school) { create(:school) }

  include_context 'when authenticated as a member of hiring staff',
                  stub_basic_auth_env: true

  context 'attempting to edit a draft vacancy' do
    scenario 'redirects to the review vacancy page' do
      vacancy = create(:vacancy, :draft, school: school)
      visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

      expect(page).to have_content("Review the vacancy for #{school.name}")
    end
  end

  context 'editing a published vacancy' do
    scenario 'takes your to the edit page' do
      vacancy = create(:vacancy, :published, school: school)
      visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

      expect(page).to have_content("Edit vacancy for #{school.name}")
    end

    context '#job_specification' do
      scenario 'can not be edited when validation fails' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)
        find(:xpath, '//div[dt[contains(text(), "Job title")]]').find('a').click
        expect(page.current_path).to eq(edit_school_vacancy_job_specification_path(school, vacancy.id))

        fill_in 'job_specification_form[job_title]', with: ''
        click_on 'Update vacancy'

        expect(page).to have_content('Job title can\'t be blank')
      end

      scenario 'can be succesfuly edited' do
        vacancy = create(:vacancy, :published, school: school)
        visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)
        find(:xpath, '//div[dt[contains(text(), "Job title")]]').find('a').click
        expect(page.current_path).to eq(edit_school_vacancy_job_specification_path(school, vacancy.id))

        fill_in 'job_specification_form[job_title]', with: 'Assistant Head Teacher'
        click_on 'Update vacancy'

        expect(page).to have_content('The vacancy has been updated')
      end
    end
  end
end
