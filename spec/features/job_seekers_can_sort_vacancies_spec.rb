require 'rails_helper'

RSpec.feature 'Sorting vacancies' do
  scenario 'Default is to be sorted by expiry date but can be sorted by published date',
           elasticsearch: true, browserstack: true do
    skip_vacancy_publish_on_validation

    first_vacancy = create(:vacancy, :published, expires_on: 7.days.from_now, publish_on: 4.days.ago)
    second_vacancy = create(:vacancy, :published, expires_on: 6.days.from_now, publish_on: 10.days.ago)
    third_vacancy = create(:vacancy, :published, expires_on: 5.days.from_now, publish_on: 8.days.ago)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    expect(page.find('.vacancy:nth-child(1)')).to have_content(third_vacancy.job_title)
    expect(page.find('.vacancy:nth-child(2)')).to have_content(second_vacancy.job_title)
    expect(page.find('.vacancy:nth-child(3)')).to have_content(first_vacancy.job_title)

    click_link I18n.t('jobs.expires_on')

    expect(page.find('.vacancy:nth-child(1)')).to have_content(first_vacancy.job_title)
    expect(page.find('.vacancy:nth-child(2)')).to have_content(second_vacancy.job_title)
    expect(page.find('.vacancy:nth-child(3)')).to have_content(third_vacancy.job_title)

    click_link I18n.t('jobs.publish_on')

    expect(page.find('.vacancy:nth-child(1)')).to have_content(first_vacancy.job_title)
    expect(page.find('.vacancy:nth-child(2)')).to have_content(third_vacancy.job_title)
    expect(page.find('.vacancy:nth-child(3)')).to have_content(second_vacancy.job_title)
  end
end
