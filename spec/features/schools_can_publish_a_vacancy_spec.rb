require 'rails_helper'

RSpec.feature 'Creating a vacancy' do
  scenario 'Users can view a vacancy creation form' do
    visit new_vacancy_path

    expect(page).to have_content('Publish a vacancy')
  end

  scenario 'Users can see validation errors when they dont fill in all required fields' do
    create(:school)

    visit new_vacancy_path
    # fill form
    fill_in 'vacancy[job_title]', with: ''
    fill_in 'vacancy[headline]', with: 'Headline'
    fill_in 'vacancy[job_description]', with: 'Job description'
    select 'Full time', from: 'vacancy[working_pattern]'
    fill_in 'vacancy[minimum_salary]', with: '25000'
    # submit form
    click_button 'Save and continue'
    expect(page).to have_content('error')
    expect(page).to have_content('Job title can\'t be blank')
  end
end