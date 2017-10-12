require 'rails_helper'

RSpec.feature 'Viewing vacancies' do

  scenario 'Only published, non-expired vacancies are visible in the list', elasticsearch: true do
    valid_vacancy = create(:vacancy)

    [:trashed, :draft, :expired,
    [:expired, :trashed], [:expired, :draft]].each { |args| create(:vacancy, *args) }

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    expect(page).to have_content(valid_vacancy.job_title)
    expect(page).to have_selector('.vacancy', count: 1)
  end

  scenario 'Vacancies should not paginate when under per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    vacancies = 2.times.map { create(:vacancy) }

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    vacancies.each { |v| expect(page).to have_content(v.job_title) }
    expect(page).to have_no_link('2')
  end

  scenario 'Vacancies should paginate when over per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
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

  scenario 'Vacancies should contain JobPosting schema.org mark up', elasticsearch: true do
    valid_vacancy = create(:vacancy, :job_schema)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    within '.vacancies' do
      expect(page).to have_selector('li[itemscope][itemtype="http://schema.org/JobPosting"]')

      within 'li[itemscope][itemtype="http://schema.org/JobPosting"]' do
        expect_schema_property_to_match_value("title",  valid_vacancy.job_title)
        expect_schema_property_to_match_value("description",  valid_vacancy.headline)
        expect_schema_property_to_match_value("responsibilities", valid_vacancy.job_description)
        expect_schema_property_to_match_value("industry", "Education")
        expect_schema_property_to_match_value("employmentType", valid_vacancy.working_pattern&.titleize)
        expect_schema_property_to_match_value("url", vacancy_url(valid_vacancy))
        expect_schema_property_to_match_value("streetAddress", valid_vacancy.school.address)
        expect_schema_property_to_match_value("postalCode", valid_vacancy.school.postcode)
        expect_schema_property_to_match_value("addressLocality", valid_vacancy.school.town)
        expect_schema_property_to_match_value("addressRegion", valid_vacancy.school.county)
        expect_schema_property_to_match_value("hiringOrganization", valid_vacancy.school.name)
        expect_schema_property_to_match_value("datePosted", valid_vacancy.publish_on.to_s(:db))
        expect_schema_property_to_match_value("validThrough", valid_vacancy.expires_on.to_s(:db))
        expect_schema_property_to_match_value("workHours", valid_vacancy.weekly_hours)
        expect_schema_property_to_match_value("currency", 'GBP')
        expect_schema_property_to_match_value("minValue", valid_vacancy.minimum_salary)
        expect_schema_property_to_match_value("maxValue", valid_vacancy.maximum_salary)
        expect_schema_property_to_match_value("educationRequirements", valid_vacancy.education)
        expect_schema_property_to_match_value("experienceRequirements", valid_vacancy.essential_requirements)
        expect_schema_property_to_match_value("jobBenefits", valid_vacancy.benefits)
      end
    end
  end
end
