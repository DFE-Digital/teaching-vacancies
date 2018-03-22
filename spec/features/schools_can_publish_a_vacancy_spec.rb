require 'rails_helper'
RSpec.feature 'Creating a vacancy' do
  before do
    create(:school)
  end

  scenario 'Searching for a school by name' do
    create(
      :school,
      name: 'Salisbury School',
      address: '495 High Street North',
      town: 'London',
      postcode: 'E12 6TH'
    )
    create(:school, name: 'Canterbury School')

    visit schools_path
    fill_in 'School name', with: 'salisbury school'
    click_on 'Find'

    expect(page).to have_content('Salisbury School')
    expect(page).to have_content('495 High Street North, London, E12 6TH')
    expect(page).not_to have_content('Canterbury School')

    click_on 'Salisbury School'

    expect(page).to have_content('Publish a vacancy for Salisbury School')
  end

  scenario 'Users can view a vacancy creation form' do
    school = create(:school, name: 'Salisbury School')
    visit new_school_vacancy_path(school_id: school.id)

    expect(page).to have_content('Publish a vacancy for Salisbury School')
  end

  scenario 'Users can see validation errors when they don\'t fill in all required fields' do
    school = create(:school)

    visit new_school_vacancy_path(school_id: school.id)
    click_button 'Save and continue'

    expect(page).to have_content('error')
    expect(page).to have_content('Job title can\'t be blank')
  end

  context 'Reviewing a vacancy' do
    scenario 'A user can review the vacancy they just posted' do
      school = create(:school)
      vacancy = VacancyPresenter.new(build(:vacancy, :complete))
      visit new_school_vacancy_path(school_id: school.id)

      expect(page).to have_content('Job specification')
      fill_in_job_specification_form_fields(vacancy)
      click_on 'Save and continue'

      expect(page).to have_content('Candidate specification')
      fill_in_candidate_specification_form_fields(vacancy)
      click_button 'Save and continue'

      expect(page).to have_content('Application details')
      fill_in_application_details_form_fields(vacancy)
      click_button 'Save and continue'

      expect(page).to have_content(I18n.t('vacancies.confirm'))

      verify_all_vacancy_details(vacancy)
    end

    scenario 'A user cannot review a vacancy that has already been published' do
      vacancy = create(:vacancy, :published)

      visit review_vacancy_path(vacancy)

      expect(page).to have_current_path(vacancy_path(vacancy))
    end
  end

  context 'A user can publish a vacancy' do
    scenario 'on submission' do
      vacancy = create(:vacancy, :draft)

      visit review_vacancy_path(vacancy)
      click_on 'Confirm and submit vacancy'

      expect(page).to have_content("The system reference number is #{vacancy.reference}")
      expect(page).to have_content('The vacancy has been posted, you can view it here:')
    end

    scenario 'at a later date' do
      vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow)

      visit review_vacancy_path(vacancy)
      click_on 'Confirm and submit vacancy'

      expect(page).to have_content("The system reference number is #{vacancy.reference}")
      expect(page).to have_content("The vacancy will be posted on #{vacancy.publish_on}, you can preview it here:")
    end
  end
end
