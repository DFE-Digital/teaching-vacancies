require 'rails_helper'
RSpec.feature 'Viewing vacancies' do
  scenario 'There are enough vacancies to invoke pagination', elasticsearch: true do
    vacancy_count = Vacancy.per_page + 1 # must be larger than the default page limit
    create_list(:vacancy, vacancy_count)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    expect(page).to have_content("There are #{vacancy_count} vacancies that match your search.")
    expect(page).to have_selector('.vacancy', count: Vacancy.per_page)
  end

  scenario 'Only vacancies satisfying all publishing conditions are listed', elasticsearch: true do
    valid_vacancy = create(:vacancy)

    expired = build(:vacancy, :expired)
    expired.send :set_slug
    expired.save(validate: false)
    [:trashed, :draft,
     %i[trashed], %i[draft]].each { |args| create(:vacancy, *args) }
    create(:vacancy, :published, publish_on: Time.zone.tomorrow)
    already_published = build(:vacancy, :published, publish_on: Time.zone.yesterday)
    already_published.send :set_slug
    already_published.save(validate: false)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    expect(page).to have_content(valid_vacancy.job_title)
    expect(page).to have_content(already_published.job_title)
    expect(page).to have_selector('.vacancy', count: 2)
  end

  scenario 'Vacancies should not paginate when under per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:per_page).and_return(2)
    vacancies = create_list(:vacancy, 2)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    vacancies.each { |v| expect(page).to have_content(v.job_title) }
    expect(page).to have_no_link('2')
  end

  scenario 'Vacancies should paginate when over per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:per_page).and_return(2)
    first_vacancy = create(:vacancy, expires_on: 5.days.from_now)
    second_vacancy = create(:vacancy, expires_on: 6.days.from_now)
    third_vacancy = create(:vacancy, expires_on: 7.days.from_now)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    expect(page).to have_content(first_vacancy.job_title)
    expect(page).to have_content(second_vacancy.job_title)
    expect(page).to_not have_content(third_vacancy.job_title)

    expect(page).to have_link('2')
  end

  scenario 'Should correctly singularize when one vacancy is returned by a search', elasticsearch: true do
    create(:vacancy)
    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path
    expect(page).to have_content(I18n.t('vacancies.vacancy_count', count: 1))
  end

  scenario 'Should correctly pluralize the number of vacancies returned by a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 3)
    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path
    expect(page).to have_content(I18n.t('vacancies.vacancy_count_plural', count: vacancies.count))
  end

  scenario 'Should advise users to widen their search when no results are returned' do
    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path
    expect(page).to have_content(I18n.t('vacancies.no_vacancies'))
  end

  context 'when the vacancy is part_time' do
    scenario 'Shows the weekly hours if there are weekly_hours' do
      vacancy = create(:vacancy, working_pattern: :part_time, weekly_hours: '5')
      Vacancy.__elasticsearch__.client.indices.flush
      visit vacancy_path(vacancy)
      expect(page).to have_content(I18n.t('vacancies.weekly_hours'))
      expect(page).to have_content(vacancy.weekly_hours)
    end
    scenario 'does not show the weekly hours if they are not set' do
      vacancy = create(:vacancy, working_pattern: :part_time, weekly_hours: nil)
      Vacancy.__elasticsearch__.client.indices.flush
      visit vacancy_path(vacancy)
      expect(page).not_to have_content(I18n.t('vacancies.weekly_hours'))
    end
  end
end
