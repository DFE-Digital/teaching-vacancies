require 'rails_helper'
RSpec.feature 'Copying a vacancy' do
  let(:school) { create(:school) }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'a job can be successfully copied and published' do
    FactoryBot.create(:vacancy, school: school)

    visit school_path

    click_on I18n.t('jobs.duplicate_link')
    click_on I18n.t('jobs.submit')

    expect(page).to have_content(I18n.t('jobs.confirmation_page.submitted'))
  end

  scenario 'hiring staff can see a Duplicate link on published jobs' do
    FactoryBot.create(:vacancy, school: school)

    visit school_path

    expect(page).to have_selector('td', text: I18n.t('jobs.duplicate_link'))
  end

  scenario 'hiring staff can see a Duplicate link on pending jobs' do
    vacancy = FactoryBot.build(:vacancy, :future_publish)
    vacancy.school = school
    vacancy.save

    visit school_path

    expect(page).to have_selector('td', text: I18n.t('jobs.duplicate_link'))
  end

  scenario 'hiring staff can NOT see a Duplicate link on draft jobs' do
    vacancy = FactoryBot.build(:vacancy, :draft)
    vacancy.school = school
    vacancy.save

    visit school_path

    expect(page).to_not have_selector('td', text: I18n.t('jobs.duplicate_link'))
  end

  context 'review page' do
    context 'copying a published job' do
      scenario 'the job title is updated to show it is a copy' do
        published = create(:vacancy, school: school, status: 'published')

        visit school_path
        click_on I18n.t('jobs.duplicate_link')

        expect(page).to have_content("#{I18n.t('jobs.copy_of')} #{published.job_title}")
      end

      scenario 'the publish_on date is updated to today' do
        published = build(:vacancy, school: school, status: 'published', publish_on: Time.zone.yesterday)
        published.send :set_slug
        published.save(validate: false)

        visit school_path
        click_on I18n.t('jobs.duplicate_link')

        dt_publish_on = page.find('dt#publish_on')
        expect(dt_publish_on.sibling('dd.app-check-your-answers__answer')).to_not have_content(published.publish_on)
        expect(dt_publish_on.sibling('dd.app-check-your-answers__answer')).to have_content(Time.zone.today)
      end
    end

    context 'copying a pending job' do
      scenario 'the job title is updated to show it is a copy' do
        pending = create(:vacancy,
                         school: school,
                         status: 'published',
                         expires_on: Time.zone.today + 4.days,
                         publish_on: Time.zone.tomorrow)

        visit school_path
        click_on I18n.t('jobs.duplicate_link')

        expect(page).to have_content("#{I18n.t('jobs.copy_of')} #{pending.job_title}")
      end
    end
  end
end
