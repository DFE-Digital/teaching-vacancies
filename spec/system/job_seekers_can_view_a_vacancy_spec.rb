require 'rails_helper'

RSpec.describe 'Viewing a single published vacancy' do
  let(:school) { create(:school) }

  scenario 'Published vacancies are viewable' do
    vacancy = create(:vacancy, :published)
    vacancy.organisation_vacancies.create(organisation: school)

    published_vacancy = VacancyPresenter.new(vacancy)

    visit job_path(published_vacancy)

    verify_vacancy_show_page_details(published_vacancy)
  end

  scenario 'Unpublished vacancies are not accessible' do
    vacancy = create(:vacancy, :draft)
    vacancy.organisation_vacancies.create(organisation: school)

    draft_vacancy = VacancyPresenter.new(vacancy)

    visit job_path(draft_vacancy)

    expect(page).to have_content('Page not found')
    expect(page).to_not have_content(draft_vacancy.job_title)
  end

  scenario 'Job post with a future publish_on date are not accessible' do
    vacancy = create(:vacancy, :future_publish)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect(page).to have_content('Page not found')
    expect(page).to_not have_content(vacancy.job_title)
  end

  scenario 'Expired vacancies display a warning message' do
    current_vacancy = create(:vacancy)
    current_vacancy.organisation_vacancies.create(organisation: school)
    expired_vacancy = build(:vacancy, :expired)
    expired_vacancy.send :set_slug
    expired_vacancy.save(validate: false)
    expired_vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(current_vacancy)
    expect(page).to have_no_content('This job post has expired')

    visit job_path(expired_vacancy)
    expect(page).to have_content('This job post has expired')
  end

  scenario 'A single vacancy must contain JobPosting schema.org mark up' do
    vacancy = create(:vacancy, :job_schema)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)

    expect(script_tag_content(wrapper_class: '.jobref'))
      .to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)).to_json)
  end

  scenario 'A vacancy without a job role' do
    vacancy = build(:vacancy, job_roles: nil)
    vacancy.send :set_slug
    vacancy.save(validate: false)
    vacancy.organisation_vacancies.create(organisation: school)

    visit job_path(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to_not have_content(I18n.t('jobs.job_roles'))
  end

  context 'A user viewing a vacancy' do
    context 'when creating a job alert' do
      let(:vacancy) { create(:vacancy, subjects: %w[Physics]) }

      before do
        vacancy.organisation_vacancies.create(organisation: school)
        visit job_path(vacancy)
      end

      scenario 'can click on the first link to create a job alert' do
        click_on I18n.t('jobs.alert.similar.terse')
        expect(page).to have_content(I18n.t('subscriptions.new.page_description'))
        expect(page).to have_content('Keyword: Physics')
        expect(page).to have_content("Location: Within 10 miles of #{school.postcode}")
        click_on I18n.t('buttons.back')
        expect(page).to have_current_path(job_path(vacancy))
      end

      scenario 'can click on the second link to create a job alert' do
        click_on I18n.t('jobs.alert.similar.verbose.link_text')
        expect(page).to have_content(I18n.t('subscriptions.new.page_description'))
        expect(page).to have_content('Keyword: Physics')
        expect(page).to have_content("Location: Within 10 miles of #{school.postcode}")
        click_on I18n.t('buttons.back')
        expect(page).to have_current_path(job_path(vacancy))
      end
    end

    scenario 'can click on the application link when there is one set' do
      vacancy = create(:vacancy, :job_schema)
      vacancy.organisation_vacancies.create(organisation: school)

      visit job_path(vacancy)

      click_on I18n.t('jobs.apply')

      expect(page.current_url).to eq vacancy.application_link
    end

    scenario 'does not see headers of empty fields' do
      vacancy = build(:vacancy, education: nil, qualifications: nil,
                                experience: nil, benefits: nil, slug: 'vacancy')
      vacancy.save(validate: false)
      vacancy.organisation_vacancies.create(organisation: school)

      visit job_path(vacancy)

      expect(page).to_not have_content(I18n.t('jobs.education'))
      expect(page).to_not have_content(I18n.t('jobs.qualifications'))
      expect(page).to_not have_content(I18n.t('jobs.experience'))
      expect(page).to_not have_content(I18n.t('jobs.benefits'))
    end

    context 'without supporting documents attached but candidate spec' do
      before do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)
        vacancy.documents = []
        vacancy.save
        visit job_path(vacancy)
      end

      scenario 'cannot see the supporting documents section' do
        expect(page).to_not have_content(I18n.t('jobs.supporting_documents'))
      end

      scenario 'can see the candidate specification sections' do
        expect(page).to have_content(I18n.t('jobs.education'))
        expect(page).to have_content(I18n.t('jobs.qualifications'))
        expect(page).to have_content(I18n.t('jobs.experience'))
      end
    end

    context 'with supporting documents attached and candidate spec' do
      before do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)
        vacancy.education = nil
        vacancy.qualifications = nil
        vacancy.experience = nil
        vacancy.save
        visit job_path(vacancy)
      end

      scenario 'can see the supporting documents section' do
        expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        expect(page).to have_content('Test.png')
      end

      scenario 'cannot see the candidate specification sections' do
        expect(page).to_not have_content(I18n.t('jobs.education'))
        expect(page).to_not have_content(I18n.t('jobs.qualifications'))
        expect(page).to_not have_content(I18n.t('jobs.experience'))
      end
    end

    scenario 'the page view is tracked' do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)

      expect { visit job_path(vacancy) }.to change { vacancy.page_view_counter.to_i }.by(1)
    end
  end

  context 'when the old vacancy URL is used' do
    scenario 'vacancy is viewable' do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      published_vacancy = VacancyPresenter.new(vacancy)

      visit vacancy_path(published_vacancy)

      expect(page).to have_content(published_vacancy.job_title)
    end

    context 'when the vacancy\'s url changes' do
      scenario 'the user is still able to use the old url' do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)
        vacancy = VacancyPresenter.new(vacancy)
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
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      vacancy = VacancyPresenter.new(vacancy)
      visit job_path(vacancy)

      expect(page.find('meta[name="description"]', visible: false)['content'])
        .to eq(strip_tags(vacancy.job_summary))
    end

    scenario 'the vacancy\'s open graph meta data are rendered correctly' do
      vacancy = create(:vacancy, :published)
      vacancy.organisation_vacancies.create(organisation: school)
      vacancy = VacancyPresenter.new(vacancy)
      visit job_path(vacancy)

      expect(page.find('meta[property="og:description"]', visible: false)['content'])
        .to eq(strip_tags(vacancy.job_summary))
    end
  end
end
