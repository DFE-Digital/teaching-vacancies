require 'rails_helper'

RSpec.feature 'Creating a vacancy' do
  scenario 'Users can view a vacancy creation form' do
    visit new_vacancy_path

    expect(page).to have_content('Publish a vacancy')
    expect(page).to have_content('Step 1 of 3')
  end

  scenario 'Users can view the stages of the form directly' do
    visit new_vacancy_path(stage: 'job_specification')
    expect(page).to have_content('Publish a vacancy')
    expect(page).to have_content('Step 1 of 3')

    visit new_vacancy_path(stage: 'candidate_specification')
    expect(page).to have_content('Publish a vacancy')
    expect(page).to have_content('Step 2 of 3')

    visit new_vacancy_path(stage: 'vacancy_specification')
    expect(page).to have_content('Publish a vacancy')
    expect(page).to have_content('Step 3 of 3')

    visit new_vacancy_path(stage: 'unknown_stage')
    expect(page).not_to have_content('Publish a vacancy')
    expect(page).to have_content('Page not found')
  end
end