require 'rails_helper'

RSpec.feature 'School viewing vacancies stats' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'A hiring school user can see the stats for all their vacancies' do
    published = create_list(:vacancy, 3, :published, school: school)
    expired = build_list(:vacancy, 4, :expired, school: school)
    expired.each { |v| v.save(validate: false) }

    all_weekly_views = published.map(&:weekly_pageviews).inject(:+) + expired.map(&:weekly_pageviews).inject(:+)
    all_total_views = published.map(&:total_pageviews).inject(:+) + expired.map(&:total_pageviews).inject(:+)
    visit school_path

    within('#statistics') do
      expect(page).to have_content(all_weekly_views)
      expect(page).to have_content(all_total_views)
    end
  end
end
