require 'rails_helper'

RSpec.feature 'Creating a vacancy' do
  scenario 'Users can view a vacancy creation form' do
    visit new_vacancy_path

    expect(page).to have_content('Publish a vacancy')
  end

  before do
    create(:school)
  end

  scenario 'Users can see validation errors when they dont fill in all required fields' do

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

  scenario 'A user can preview the vacancy they just posted' do
    vacancy =  build(:vacancy)
    visit new_vacancy_path

    fill_in 'vacancy[job_title]', with: vacancy.job_title
    fill_in 'vacancy[headline]', with: vacancy.headline
    fill_in 'vacancy[job_description]', with: vacancy.job_description
    select vacancy.working_pattern.humanize, from: 'vacancy[working_pattern]'
    fill_in 'vacancy[minimum_salary]', with: vacancy.minimum_salary
    fill_in 'vacancy[essential_requirements]', with: vacancy.essential_requirements
    select '9', from: 'vacancy[expires_on(3i)]'
    select 'July', from: 'vacancy[expires_on(2i)]'
    select Time.now.year+1, from: 'vacancy[expires_on(1i)]'

    click_button 'Save and continue'

    expect(page).to have_content("Confirm details before you submit")
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.headline)
    expect(page).to have_content(number_to_currency(vacancy.minimum_salary, precision: 0))
    expect(page).to have_content(vacancy.essential_requirements)
  end
end
