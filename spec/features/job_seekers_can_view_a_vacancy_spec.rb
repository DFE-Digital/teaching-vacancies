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

    scenario 'does not see the Weekly hours label for part time roles that don\'t have weekly hours set' do
      vacancy = build(:vacancy, :published_slugged, working_pattern: :part_time, weekly_hours: nil)
      vacancy.save(validate: false)

      visit job_path(vacancy)

      expect(page).to_not have_content(I18n.t('jobs.weekly_hours'))
    end

    scenario 'can see the Weekly hours label for part time roles do have weekly hours set' do
      vacancy = build(:vacancy, :published_slugged, working_pattern: :part_time, weekly_hours: 30)
      vacancy.save(validate: false)

      visit job_path(vacancy)

      expect(page).to have_content(I18n.t('jobs.weekly_hours'))
      expect(page).to have_content(30)
    end

    scenario 'the page view is tracked' do
      vacancy = create(:vacancy, :published)

      expect { visit job_path(vacancy) }.to change { vacancy.page_view_counter.to_i }.by(1)
    end
  end

  context 'when the old vacancy URL is used' do
    scenario 'vacancy is viewable' do
      published_vacancy = VacancyPresenter.new(create(:vacancy, :published))

      visit vacancy_path(published_vacancy)

      expect(page).to have_content(published_vacancy.job_title)
    end

    context 'when the vacancy\'s url changes' do
      scenario 'the user is still able to use the old url' do
        vacancy = VacancyPresenter.new(create(:vacancy, :published))
        old_path = job_path(vacancy)
        vacancy.job_title = 'A new job title'
        vacancy.refresh_slug
        vacancy.save
        new_path = job_path(vacancy)

        visit old_path

        expect(page.current_path).to eq(new_path)
      end
    end
  end

  context 'meta tags' do
    include ActionView::Helpers::SanitizeHelper
    scenario 'the vacancy\'s meta data are rendered correctly' do
      vacancy = VacancyPresenter.new(create(:vacancy, :published))
      visit job_path(vacancy)

      expect(page.find('meta[name="description"]', visible: false)['content'])
        .to eq(strip_tags(vacancy.job_description))
    end

    scenario 'the vacancy\'s open graph meta data are rendered correctly' do
      vacancy = VacancyPresenter.new(create(:vacancy, :published))
      visit job_path(vacancy)

      expect(page.find('meta[property="og:description"]', visible: false)['content'])
        .to eq(strip_tags(vacancy.job_description))
    end
  end
end
