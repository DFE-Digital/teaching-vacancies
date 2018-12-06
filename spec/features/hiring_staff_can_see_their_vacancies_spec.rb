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

  context 'viewing the lists of jobs on the school page' do
    let(:school) { create(:school) }

    before do
      stub_hiring_staff_auth(urn: school.urn)
    end

    scenario 'with published vacancies' do
      5.times do
        create(:vacancy, school: school, status: 'published')
      end

      visit school_path

      expect(page).to have_content('Published jobs')
    end

    scenario 'with draft vacancies' do
      3.times do
        create(:vacancy, school: school, status: 'draft')
      end

      visit school_path

      expect(page).to have_content('Draft jobs')
    end

    scenario 'with pending vacancies' do
      publish_on = Time.zone.today + 2.days
      expires_on = Time.zone.today + 4.days
      7.times do
        create(:vacancy, school: school, status: 'published', expires_on: expires_on, publish_on: publish_on)
      end

      visit school_path

      expect(page).to have_content('Pending jobs')
    end

    scenario 'with expired vacancies' do
      expired = build(:vacancy, school: school, status: 'published', expires_on: Faker::Time.backward(6))
      expired.send :set_slug
      expired.save(validate: false)

      visit school_path

      expect(page).to have_content('Expired jobs')
    end
  end
end
