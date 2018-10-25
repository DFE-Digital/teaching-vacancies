require 'rails_helper'

RSpec.feature 'Hiring staff viewing their vacancies' do
  let(:school) { create(:school) }
  let!(:vacancy) { create(:vacancy, school: school, status: 'published') }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'can get to the vacancy preview page' do
    visit school_path

    click_on(vacancy.job_title)

    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.job_description)
  end

  scenario 'can see stats for a vacancy' do
    get_information_count = 4
    get_information_count.times do
      Auditor::Audit.new(vacancy, 'vacancy.get_more_information', nil).log
    end
    visit school_job_path(vacancy.id)

    within '#statistics' do
      expect(page).to have_content(vacancy.weekly_pageviews)
      expect(page).to have_content(vacancy.total_pageviews)
      expect(page).to have_content(get_information_count)
    end
  end
end
