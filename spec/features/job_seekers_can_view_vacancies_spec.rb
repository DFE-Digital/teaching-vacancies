require 'rails_helper'
RSpec.feature 'Viewing vacancies' do
  scenario 'There are enough vacancies to invoke pagination', elasticsearch: true do
    job_count = Vacancy.default_per_page + 1 # must be larger than the default page limit
    create_list(:vacancy, job_count)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    expect(page).to have_content("There are #{job_count} jobs listed.")
    expect(page).to have_selector('.vacancy', count: Vacancy.default_per_page)
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
    visit jobs_path

    expect(page).to have_content(valid_vacancy.job_title)
    expect(page).to have_content(already_published.job_title)
    expect(page).to have_selector('.vacancy', count: 2)
  end

  scenario 'Vacancies should not paginate when under per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    vacancies = create_list(:vacancy, 2)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    vacancies.each { |v| expect(page).to have_content(v.job_title) }
    expect(page).to have_no_link('2')
  end

  scenario 'Vacancies should paginate when over per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    first_vacancy = create(:vacancy, expires_on: 5.days.from_now)
    second_vacancy = create(:vacancy, expires_on: 6.days.from_now)
    third_vacancy = create(:vacancy, expires_on: 7.days.from_now)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    expect(page).to have_content(first_vacancy.job_title)
    expect(page).to have_content(second_vacancy.job_title)
    expect(page).to_not have_content(third_vacancy.job_title)

    expect(page).to have_link('2')
  end

  scenario 'Should correctly singularize when one vacancy is returned by a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 1, subject: create(:subject, name: 'English'))
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    within '.filters-form' do
      fill_in 'keyword', with: 'English'
      page.find('.button[type=submit]').click
    end
    expect(page).to have_content(I18n.t('jobs.job_count', count: vacancies.count))
  end

  scenario 'Should correctly pluralize the number of vacancies returned by a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 3, subject: create(:subject, name: 'English'))
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    within '.filters-form' do
      fill_in 'keyword', with: 'English'
      page.find('.button[type=submit]').click
    end
    expect(page).to have_content(I18n.t('jobs.job_count_plural', count: vacancies.count))
  end

  scenario 'Should correctly singularize the number of vacancies returned without a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 1)
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    expect(page).to have_content(I18n.t('jobs.job_count_without_search', count: vacancies.count))
  end

  scenario 'Should correctly pluralize the number of vacancies returned without a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 3)
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    expect(page).to have_content(I18n.t('jobs.job_count_plural_without_search', count: vacancies.count))
  end

  scenario 'Should advise users to widen their search when no results are returned' do
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    click_on I18n.t('buttons.apply_filters')
    expect(page).to have_content(I18n.t('jobs.no_jobs'))
  end

  scenario 'Should advise users to check back soon when no jobs are listed' do
    visit jobs_path
    I18n.t('jobs.none_listed').each do |sentence|
      expect(page).to have_content(sentence)
    end
    expect(page).not_to have_content(I18n.t('jobs.no_jobs'))
  end

  context 'when the vacancy is part_time' do
    scenario 'Shows the weekly hours if there are weekly_hours' do
      vacancy = create(:vacancy, working_pattern: :part_time, weekly_hours: '5')
      Vacancy.__elasticsearch__.client.indices.flush
      visit job_path(vacancy)
      expect(page).to have_content(I18n.t('jobs.weekly_hours'))
      expect(page).to have_content(vacancy.weekly_hours)
    end

    scenario 'does not show the weekly hours if they are not set' do
      vacancy = create(:vacancy, working_pattern: :part_time, weekly_hours: nil)
      Vacancy.__elasticsearch__.client.indices.flush
      visit job_path(vacancy)
      expect(page).not_to have_content(I18n.t('jobs.weekly_hours'))
    end
  end
end
