require 'rails_helper'

RSpec.feature 'Viewing vacancies' do
  scenario 'Only published, non-expired vacancies are visible in the list' do
    valid_vacancy = create(:vacancy)

    create(:vacancy, :trashed)
    create(:vacancy, :draft)
    create(:vacancy, :expired)
    create(:vacancy, :expired, :trashed)
    create(:vacancy, :expired, :draft)

    visit vacancies_path

    expect(page).to have_content(valid_vacancy.job_title)
    expect(page).to have_selector('.vacancy', count: 1)
  end
end