require 'rails_helper'
RSpec.feature 'School deleting vacancies' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'Hiring staff should see a delete button for a vacancy' do
    vacancy = create(:vacancy, school: school)

    visit school_path(school.id)

    within("tr#vacancy_#{vacancy.id}") do
      expect(page).to have_content(I18n.t('buttons.delete'))
    end
  end

  scenario 'A school can delete a vacancy from a list' do
    vacancy1 = create(:vacancy, school: school)
    vacancy2 = create(:vacancy, school: school)

    visit school_path(school.id)
    within("tr#vacancy_#{vacancy1.id}") do
      click_on 'Delete'
    end

    expect(page).not_to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
    expect(page).to have_content('The vacancy has been deleted')
  end
end
