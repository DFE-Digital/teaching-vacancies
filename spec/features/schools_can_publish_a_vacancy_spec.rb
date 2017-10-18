require 'rails_helper'
RSpec.feature 'Creating a vacancy' do
  before do
    create(:school)
  end

  scenario 'Users can view a vacancy creation form' do
    visit new_vacancy_path

    expect(page).to have_content('Publish a vacancy')
  end

  scenario 'Users can see validation errors when they don\'t fill in all required fields' do
    vacancy = build(:vacancy, job_title: '')

    visit new_vacancy_path
    fill_vacancy_fields(vacancy)

    expect(page).to have_content('error')
    expect(page).to have_content('Job title can\'t be blank')
  end

  context "Reviewing a vacancy" do
    scenario 'A user can review the vacancy they just posted' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      visit new_vacancy_path

      fill_vacancy_fields(vacancy)

      expect(page).to have_content('Confirm details before you submit')
      expect(page).to have_content(vacancy.job_title)
      expect(page).to have_content(vacancy.headline)
      expect(page).to have_content(vacancy.salary_range('to'))
      expect(page).to have_content(vacancy.essential_requirements)
      expect(page).to have_content(vacancy.contact_email)
    end


    scenario 'A user cannot review a vacancy that has already been published' do
      vacancy = create(:vacancy, :published)

      visit review_vacancy_path(vacancy)

      expect(page).to have_current_path(vacancy_path(vacancy))
    end
  end

  context 'A user can publish a vacancy' do
    scenario 'on submission' do
      vacancy = create(:vacancy)

      visit review_vacancy_path(vacancy)
      click_on 'Confirm and submit vacancy'

      expect(page).to have_content("The system reference number is #{vacancy.reference}")
      expect(page).to have_content('The vacancy has been posted, you can view it here:')
    end

    scenario 'at a later date' do
      vacancy = create(:vacancy, publish_on: Time.zone.tomorrow)

      visit review_vacancy_path(vacancy)
      click_on 'Confirm and submit vacancy'

      expect(page).to have_content("The system reference number is #{vacancy.reference}")
      expect(page).to have_content("The vacancy will be posted on #{vacancy.publish_on}, you can preview it here:")
    end
  end
end
