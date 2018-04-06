require 'rails_helper'

RSpec.feature 'Viewing a single published vacancy' do
  scenario 'Published vacancies are viewable' do
    published_vacancy = VacancyPresenter.new(create(:vacancy, :published))

    visit vacancy_path(published_vacancy)

    expect(page).to have_content(published_vacancy.job_title)
    expect(page).to have_content(published_vacancy.headline)
    expect(page).to have_content(published_vacancy.job_description)
    expect(page).to have_content(published_vacancy.salary_range)
    expect(page).to have_content(published_vacancy.contact_email)
  end

  scenario 'Unpublished vacancies are not viewable' do
    draft_vacancy = create(:vacancy, :draft)

    visit vacancy_path(draft_vacancy)

    expect(page).to have_content('Page not found')
    expect(page).to_not have_content(draft_vacancy.job_title)
  end

  scenario 'Expired vacancies display a warning message' do
    current_vacancy = create(:vacancy)
    expired_vacancy = build(:vacancy, :expired)
    expired_vacancy.send :set_slug
    expired_vacancy.save(validate: false)

    visit vacancy_path(current_vacancy)
    expect(page).to have_no_content('This vacancy has expired')

    visit vacancy_path(expired_vacancy)
    expect(page).to have_content('This vacancy has expired')
  end

  scenario 'A single vacancy must contain JobPosting schema.org mark up', elasticsearch: true do
    vacancy = create(:vacancy, :job_schema)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancy_path(vacancy)

    expect(script_tag_content(wrapper_class: '.jobref')).to eq(vacancy_json_ld(vacancy).to_json)
  end

  context 'A user viewing a vacancy' do
    scenario 'can click on the application link when there is one set' do
      vacancy = create(:vacancy, :job_schema)
      visit vacancy_path(vacancy)
      click_on 'Apply for this job'

      expect(page.current_url).to eq vacancy.application_link
    end
  end
end
