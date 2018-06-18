require 'rails_helper'

RSpec.feature 'Viewing a single published vacancy' do
  scenario 'Published vacancies are viewable' do
    published_vacancy = VacancyPresenter.new(create(:vacancy, :published))

    visit job_path(published_vacancy)

    verify_vacancy_show_page_details(published_vacancy)
  end

  scenario 'Unpublished vacancies are not accessible' do
    draft_vacancy = create(:vacancy, :draft)

    visit job_path(draft_vacancy)

    expect(page).to have_content('Page not found')
    expect(page).to_not have_content(draft_vacancy.job_title)
  end

  scenario 'Job post with a future publish_on date are not accessible' do
    job_post = create(:vacancy, :future_publish)

    visit job_path(job_post)

    expect(page).to have_content('Page not found')
    expect(page).to_not have_content(job_post.job_title)
  end

  scenario 'Expired vacancies display a warning message' do
    current_vacancy = create(:vacancy)
    expired_vacancy = build(:vacancy, :expired)
    expired_vacancy.send :set_slug
    expired_vacancy.save(validate: false)

    visit job_path(current_vacancy)
    expect(page).to have_no_content('This job post has expired')

    visit job_path(expired_vacancy)
    expect(page).to have_content('This job post has expired')
  end

  scenario 'A single vacancy must contain JobPosting schema.org mark up' do
    vacancy = create(:vacancy, :job_schema)

    visit job_path(vacancy)

    expect(script_tag_content(wrapper_class: '.jobref'))
      .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
  end

  context 'A user viewing a vacancy' do
    scenario 'can click on the application link when there is one set' do
      vacancy = create(:vacancy, :job_schema)
      visit job_path(vacancy)

      click_on 'Get more information'

      expect(page.current_url).to eq vacancy.application_link
    end

    scenario 'does not see headers of empty fields' do
      vacancy = build(:vacancy, education: nil, qualifications: nil,
                                experience: nil, benefits: nil, slug: 'vacancy')
      vacancy.save(validate: false)

      visit job_path(vacancy)

      expect(page).to_not have_content(I18n.t('jobs.education'))
      expect(page).to_not have_content(I18n.t('jobs.qualifications'))
      expect(page).to_not have_content(I18n.t('jobs.experience'))
      expect(page).to_not have_content(I18n.t('jobs.benefits'))
    end
  end

  context 'when the old vacancy URL is used' do
    scenario 'vacancy is viewable' do
      published_vacancy = VacancyPresenter.new(create(:vacancy, :published))

      visit vacancy_path(published_vacancy)

      expect(page).to have_content(published_vacancy.job_title)
    end
  end
end
