require 'rails_helper'

RSpec.feature 'Filtering vacancies' do
  scenario 'Filterable by keyword', elasticsearch: true do
    headmaster = create(:vacancy, :published, job_title: 'Headmaster')
    languages_teacher = create(:vacancy, :published, job_title: 'Languages Teacher')

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    within '.filters-form' do
      fill_in 'keyword', with: 'Headmaster'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(headmaster.job_title)
    expect(page).not_to have_content(languages_teacher.job_title)
  end
end