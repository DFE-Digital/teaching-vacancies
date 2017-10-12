require 'rails_helper'

RSpec.feature 'Creating a vacancy' do

  before do
    create(:school)
  end

  scenario 'Users can view a vacancy creation form' do
    visit new_vacancy_path

    expect(page).to have_content('Publish a vacancy')
  end

  scenario 'Users can see validation errors when they dont fill in all required fields' do
    vacancy = build(:vacancy, job_title: '')

    visit new_vacancy_path
    fill_vacancy_fields(vacancy)

    expect(page).to have_content('error')
    expect(page).to have_content('Job title can\'t be blank')
  end

  scenario 'A user can review the vacancy they just posted' do
    vacancy = build(:vacancy)
    visit new_vacancy_path

    fill_vacancy_fields(vacancy)

    expect(page).to have_content("Confirm details before you submit")
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.headline)
    expect(page).to have_content(vacancy_salary_range(vacancy.minimum_salary, vacancy.maximum_salary))
    expect(page).to have_content(vacancy.essential_requirements)
  end

  scenario 'A user can publish a vacancy' do

    vacancy = create(:vacancy)

    visit review_vacancy_path(vacancy)
    click_on "Confirm and submit vacancy"

    expect(page).to have_content("Vacancy submitted")
    expect(page).to have_content("The system reference number is #{vacancy.reference}")
  end
end
