require 'rails_helper'
RSpec.feature 'Creating a vacancy' do
  let(:school) { create(:school) }

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
    visit new_school_vacancy_path(school.id)

    expect(page).to have_content('Publish a vacancy for Salisbury School')
  end

  context 'Users can see validation errors when they don\'t fill in all required fields' do
    scenario 'on the first page' do
      visit new_school_vacancy_path(school.id)

      # Don't fill in any information to force all errors to show
      click_button 'Save and continue'

      within('.error-summary') do
        expect(page).to have_content('5 errors prevented this vacancy from being saved:')
      end

      within_row_for(text: I18n.t('vacancies.job_title')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_title.blank'))
      end

      within_row_for(text: I18n.t('vacancies.headline')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.headline.blank'))
      end

      within_row_for(text: I18n.t('vacancies.description')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_description.blank'))
      end

      within_row_for(text: I18n.t('vacancies.salary_range')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.minimum_salary.blank'))
      end

      within_row_for(text: I18n.t('vacancies.working_pattern')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.working_pattern.blank'))
      end
    end

    scenario 'on the second page' do
      visit new_school_vacancy_path(school.id)

      fill_in 'vacancy[job_title]', with: 'title'
      fill_in 'vacancy[headline]', with: 'headline'
      fill_in 'vacancy[job_description]', with: 'description'
      select 'Full time', from: 'vacancy[working_pattern]'
      fill_in 'vacancy[minimum_salary]', with: 0
      fill_in 'vacancy[maximum_salary]', with: 1
      click_button 'Save and continue'

      expect(page).to have_content('Step 2 of 3')

      # Don't fill in any information to force all errors to show
      click_button 'Save and continue'

      within('.error-summary') do
        expect(page).to have_content('1 error prevented this vacancy from being saved:')
      end

      within_row_for(text: I18n.t('vacancies.essential_requirements')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.working_pattern.blank'))
      end
    end

    scenario 'on the third page' do
      visit new_school_vacancy_path(school.id)

      fill_in 'vacancy[job_title]', with: 'title'
      fill_in 'vacancy[headline]', with: 'headline'
      fill_in 'vacancy[job_description]', with: 'description'
      select 'Full time', from: 'vacancy[working_pattern]'
      fill_in 'vacancy[minimum_salary]', with: 0
      fill_in 'vacancy[maximum_salary]', with: 1
      click_button 'Save and continue'

      expect(page).to have_content('Step 2 of 3')

      fill_in 'vacancy[essential_requirements]', with: 'essential requirements'
      click_button 'Save and continue'

      expect(page).to have_content('Step 3 of 3')

      # Don't fill in any information to force all errors to show
      click_button 'Save and continue'

      within('.error-summary') do
        expect(page).to have_content('3 errors prevented this vacancy from being saved:')
      end

      within_row_for(text: I18n.t('vacancies.contact_email')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.contact_email.blank'))
      end

      within_row_for(element: 'legend', text: I18n.t('vacancies.deadline_date')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.blank'))
      end

      within_row_for(element: 'legend', text: I18n.t('vacancies.publication_date')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.blank'))
      end

      # Fill in a date in the past
      fill_in 'vacancy[publish_on_dd]', with: '01'
      fill_in 'vacancy[publish_on_mm]', with: '01'
      fill_in 'vacancy[publish_on_yyyy]', with: '2001'

      click_button 'Save and continue'

      within_row_for(element: 'legend', text: I18n.t('vacancies.publication_date')) do
        expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today'))
      end

      # Fill in valid information
      fill_in 'vacancy[contact_email]', with: 'foo@bar.com'

      fill_in 'vacancy[expires_on_dd]', with: '01'
      fill_in 'vacancy[expires_on_mm]', with: '01'
      fill_in 'vacancy[expires_on_yyyy]', with: '2999'

      fill_in 'vacancy[publish_on_dd]', with: '01'
      fill_in 'vacancy[publish_on_mm]', with: '01'
      fill_in 'vacancy[publish_on_yyyy]', with: '2999'

      click_button 'Save and continue'

      expect(page).to have_content('Confirm details before you submit')
    end
  end

  context 'Reviewing a vacancy' do
    scenario 'A user can review the vacancy they just posted' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      visit new_school_vacancy_path(school.id)

      expect(page).to have_content('Job specification')
      fill_in_job_spec_fields(vacancy)

      expect(page).to have_content('Candidate specification')
      fill_in_candidate_specification_fields(vacancy)
      click_button 'Save and continue'

      expect(page).to have_content('Application details')
      fill_in_application_details_fields(vacancy)
      click_button 'Save and continue'

      expect(page).to have_content(I18n.t('vacancies.confirm'))
      expect(page).to have_content(vacancy.job_title)
      expect(page).to have_content(vacancy.headline)
      expect(page).to have_content(vacancy.salary_range('to'))
      expect(page).to have_content(vacancy.essential_requirements)
      expect(page).to have_content(vacancy.contact_email)
    end

    scenario 'A user cannot review a vacancy that has already been published' do
      vacancy = create(:vacancy, :published)

      visit review_school_vacancy_path(school.id, vacancy)

      expect(page).to have_current_path(school_vacancy_path(school.id, vacancy))
    end
  end

  context 'A user can publish a vacancy' do
    scenario 'on submission' do
      vacancy = create(:vacancy, :draft)

      visit review_school_vacancy_path(school.id, vacancy)
      click_on 'Confirm and submit vacancy'

      expect(page).to have_content("The system reference number is #{vacancy.reference}")
      expect(page).to have_content('The vacancy has been posted, you can view it here:')
    end

    scenario 'at a later date' do
      vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow)

      visit review_school_vacancy_path(school.id, vacancy)
      click_on 'Confirm and submit vacancy'

      expect(page).to have_content("The system reference number is #{vacancy.reference}")
      expect(page).to have_content("The vacancy will be posted on #{vacancy.publish_on}, you can preview it here:")
    end
  end

  def within_row_for(element: 'label', text:, &block)
    element = page.find(element, text: text).find(:xpath, '..')
    within(element, &block)
  end
end
