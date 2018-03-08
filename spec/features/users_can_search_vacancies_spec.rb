require 'rails_helper'

RSpec.feature 'Searching vacancies by keyword' do
  scenario 'searching for the exact job title', elasticsearch: true do
    vacancy = create(:vacancy, job_title: 'Maths Teacher')

    Vacancy.__elasticsearch__.client.indices.flush

    visit vacancies_path

    expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

    within '.filters-form' do
      fill_in 'keyword', with: vacancy.job_title
      page.find('.button[type=submit]').click
    end

    expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
  end

  scenario 'searching for the a partial job title', elasticsearch: true do
    vacancy = create(:vacancy, job_title: 'Maths Teacher')

    Vacancy.__elasticsearch__.client.indices.flush

    visit vacancies_path

    expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

    within '.filters-form' do
      fill_in 'keyword', with: 'Math'
      page.find('.button[type=submit]').click
    end

    expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
  end

  scenario 'searching for a word in the job title that has a single typo', elasticsearch: true do
    vacancy = create(:vacancy, job_title: 'Maths Teacher')

    Vacancy.__elasticsearch__.client.indices.flush

    visit vacancies_path

    expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)

    within '.filters-form' do
      fill_in 'keyword', with: 'Maht'
      page.find('.button[type=submit]').click
    end

    expect(page.find('.vacancy:eq(1)')).to have_content(vacancy.job_title)
  end
end
