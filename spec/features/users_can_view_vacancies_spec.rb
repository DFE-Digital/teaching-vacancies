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

  scenario 'Vacancies should not paginate when under per-page limit' do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    first_vacancy = create(:vacancy)
    second_vacancy = create(:vacancy)

    visit vacancies_path

    expect(page).to have_content(first_vacancy.job_title)
    expect(page).to have_content(second_vacancy.job_title)

    expect(page).to have_no_link('2')
  end

  scenario 'Vacancies should paginate when over per-page limit' do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    first_vacancy = create(:vacancy)
    second_vacancy = create(:vacancy)
    third_vacancy = create(:vacancy)

    visit vacancies_path

    expect(page).to have_content(first_vacancy.job_title)
    expect(page).to have_content(second_vacancy.job_title)
    expect(page).to_not have_content(third_vacancy.job_title)

    expect(page).to have_link('2')
  end

  scenario 'Vacancies should contain JobPosting schema.org mark up' do
    valid_vacancy = create(:vacancy)

    visit vacancies_path

    within '.vacancies' do
      expect(page).to have_selector('li[itemscope][itemtype="http://schema.org/JobPosting"]')

      within 'li[itemscope][itemtype="http://schema.org/JobPosting"]' do
        expect(page).to have_selector('meta[itemprop="title"][content="'+valid_vacancy.job_title+'"]')
        expect(page).to have_selector('meta[itemprop="description"][content="'+valid_vacancy.headline+'"]')
        expect(page).to have_selector('meta[itemprop="responsibilities"][content="'+valid_vacancy.job_description+'"]')
      end
    end
  end
end