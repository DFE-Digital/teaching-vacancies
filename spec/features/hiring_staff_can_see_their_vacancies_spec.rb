require 'rails_helper'

RSpec.feature 'Hiring staff can see their vacancies' do
  scenario 'school with geolocation' do
    school = create(:school, northing: '1', easting: '2')

    stub_hiring_staff_auth(urn: school.urn)
    vacancy = create(:vacancy, school: school, status: 'published')

    visit school_path

    click_on(vacancy.job_title)

    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.job_summary)
  end

  context 'with no jobs' do
    scenario 'hiring staff see a message informing them they have no jobs' do
      school = create(:school)

      stub_hiring_staff_auth(urn: school.urn)
      visit school_path

      expect(page).to have_content(I18n.t('schools.no_jobs.heading'))
    end
  end

  context 'viewing the lists of jobs on the school page' do
    let(:school) { create(:school) }

    let!(:published_vacancy) { create(:vacancy, :published, school: school) }
    let!(:draft_vacancy) { create(:vacancy, :draft, school: school) }
    let!(:pending_vacancy) { create(:vacancy, :future_publish, school: school) }
    let!(:expired_vacancy) do
      expired_vacancy = build(:vacancy, :expired, school: school)
      expired_vacancy.save(validate: false)
      expired_vacancy
    end

    before do
      stub_hiring_staff_auth(urn: school.urn)
    end

    scenario 'jobs are split into sections' do
      5.times do
        create(:vacancy, :published, school: school)
      end

      visit school_path

      expect(page).to have_content(I18n.t('jobs.published_jobs'))
      expect(page).to have_content(I18n.t('jobs.draft_jobs'))
      expect(page).to have_content(I18n.t('jobs.pending_jobs'))
      expect(page).to have_content(I18n.t('jobs.expired_jobs'))
    end

    scenario 'with published vacancies' do
      visit school_path

      within('.tab-list') do
        click_on(I18n.t('jobs.published_jobs'))
      end

      within('table.vacancies') do
        expect(page).to have_content(I18n.t('jobs.job_title'))
        expect(page).to have_content(I18n.t('jobs.publish_on'))
        expect(page).to have_content(published_vacancy.job_title)
        expect(page).to have_css('tbody tr', count: 1)
      end
    end

    scenario 'with draft vacancies' do
      visit school_path

      within('.tab-list') do
        click_on(I18n.t('jobs.draft_jobs'))
      end

      within('table.vacancies') do
        expect(page).to have_content(I18n.t('jobs.draft.time_created'))
        expect(page).to have_content(format_date(draft_vacancy.created_at))
        expect(page).to have_content(format_date(draft_vacancy.updated_at))
        expect(page).to have_content(draft_vacancy.job_title)
        expect(page).to have_css('tbody tr', count: 1)
      end
    end

    scenario 'with pending vacancies' do
      visit school_path

      within('.tab-list') do
        click_on(I18n.t('jobs.pending_jobs'))
      end

      within('table.vacancies') do
        expect(page).to have_content(I18n.t('jobs.date_to_be_posted'))
        expect(page).to have_content(pending_vacancy.job_title)
        expect(page).to have_content(format_date(pending_vacancy.publish_on))
        expect(page).to have_content(format_date(pending_vacancy.expires_on))
        expect(page).to have_css('tbody tr', count: 1)
      end
    end

    scenario 'with expired vacancies' do
      visit school_path

      within('.tab-list') do
        click_on(I18n.t('jobs.expired_jobs'))
      end

      within('table.vacancies') do
        expect(page).to have_content(I18n.t('jobs.expired_on'))
        expect(page).to have_content(expired_vacancy.job_title)
        expect(page).to have_content(format_date(expired_vacancy.expires_on))
        expect(page).to have_content(format_date(expired_vacancy.publish_on))
        expect(page).to have_css('tbody tr', count: 1)
      end
    end

    context 'when a draft vacancy has been updated' do
      let!(:draft_vacancy) do
        create(:vacancy, :draft, school: school, created_at: 3.days.ago, updated_at: 1.day.ago)
      end

      scenario 'shows the last updated at' do
        draft_vacancy
        visit school_path

        within('.tab-list') do
          click_on(I18n.t('jobs.draft_jobs'))
        end

        within('table.vacancies') do
          expect(page).to have_content(format_date(draft_vacancy.created_at))
          expect(page).to have_content(format_date(draft_vacancy.updated_at))
        end
      end
    end
  end
end
