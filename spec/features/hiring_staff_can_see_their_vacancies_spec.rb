require 'rails_helper'

RSpec.feature 'Hiring staff can see their vacancies' do
  scenario 'school with geolocation' do
    school = create(:school, northing: '1', easting: '2')

    stub_hiring_staff_auth(urn: school.urn)
    vacancy = create(:vacancy, school: school, status: 'published')

    visit school_path

    click_on(vacancy.job_title)

    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.job_description)
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

    before do
      stub_hiring_staff_auth(urn: school.urn)
    end

    scenario 'jobs are split into sections' do
      5.times do
        create(:vacancy, school: school, status: 'published')
      end

      visit school_path

      expect(page).to have_content(I18n.t('jobs.published_jobs'))
      expect(page).to have_content(I18n.t('jobs.draft_jobs'))
      expect(page).to have_content(I18n.t('jobs.pending_jobs'))
      expect(page).to have_content(I18n.t('jobs.expired_jobs'))
    end

    scenario 'with published vacancies' do
      vacancy = create(:vacancy, school: school, status: 'published')

      visit school_path

      table = page.find('section#published-jobs table')
      expect(table).to have_selector('th', text: I18n.t('jobs.job_title'))
      expect(table).to have_selector('td', text: vacancy.job_title)
    end

    scenario 'with draft vacancies' do
      vacancy = create(:vacancy, school: school, status: 'draft')

      visit school_path

      table = page.find('section#draft-jobs table')
      expect(table).to have_selector('th', text: I18n.t('jobs.date_drafted'))
      expect(table).to have_selector('td', text: vacancy.job_title)
    end

    scenario 'with pending vacancies' do
      publish_on = Time.zone.today + 2.days
      expires_on = Time.zone.today + 4.days
      vacancy = create(:vacancy, school: school, status: 'published', expires_on: expires_on, publish_on: publish_on)

      visit school_path

      table = page.find('section#pending-jobs table')
      expect(table).to have_selector('th', text: I18n.t('jobs.date_to_be_posted'))
      expect(table).to have_selector('td', text: vacancy.job_title)
    end

    scenario 'with expired vacancies' do
      expired = build(:vacancy, school: school, status: 'published', expires_on: Faker::Time.backward(6))
      expired.send :set_slug
      expired.save(validate: false)

      visit school_path

      table = page.find('section#expired-jobs table')
      expect(table).to have_selector('th', text: I18n.t('jobs.expired_on'))
      expect(table).to have_selector('td', text: expired.job_title)
    end

    context 'tabs are clickable' do
      scenario 'clicking on the Draft jobs tab shows draft jobs', js: true do
        published_vacancy = create(:vacancy, school: school, status: 'published')
        draft_vacancy = create(:vacancy, school: school, status: 'draft')

        visit school_path

        click_on(I18n.t('jobs.draft_jobs'))
        expect(page).to_not have_selector('h2', text: I18n.t('jobs.published_jobs'))
        expect(page).to_not have_selector('td', text: published_vacancy.job_title)
        expect(page).to have_selector('td', text: draft_vacancy.job_title)
      end

      scenario 'clicking on the Pending jobs tab shows pending jobs', js: true do
        published_vacancy = create(:vacancy, school: school, status: 'published')
        draft_vacancy = create(:vacancy, school: school, status: 'draft')
        publish_on = Time.zone.today + 2.days
        expires_on = Time.zone.today + 4.days
        pending_vacancy = create(:vacancy,
                                 school: school,
                                 status: 'published',
                                 expires_on: expires_on,
                                 publish_on: publish_on)

        visit school_path

        click_on(I18n.t('jobs.pending_jobs'))
        expect(page).to_not have_selector('h2', text: I18n.t('jobs.published_jobs'))
        expect(page).to_not have_selector('h2', text: I18n.t('jobs.draft_jobs'))
        expect(page).to_not have_selector('td', text: published_vacancy.job_title)
        expect(page).to_not have_selector('td', text: draft_vacancy.job_title)
        expect(page).to have_selector('h2', text: I18n.t('jobs.pending_jobs'))
        expect(page).to have_selector('td', text: pending_vacancy.job_title)
      end

      scenario 'there is a no content message within empty tabs', js: true do
        create(:vacancy, school: school, status: 'published')

        visit school_path

        click_on(I18n.t('jobs.draft_jobs'))
        section = page.find('section#draft-jobs')
        expect(section).to have_content(I18n.t('jobs.no_draft_jobs'))
      end
    end
  end
end
