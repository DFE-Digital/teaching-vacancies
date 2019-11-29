require 'rails_helper'

RSpec.feature 'Viewing a location category landing page' do
  scenario 'search results can be filtered by the location category' do
    allow(LocationCategory).to receive(:include?).with('camden').and_return(true)

    london_region = Region.find_or_create_by(name: 'London')
    camden_vacancy = create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Camden'))
    victoria_vacancy = create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Victoria'))

    Vacancy.__elasticsearch__.client.indices.flush

    visit location_category_path('camden')

    expect(page).to have_content(camden_vacancy.job_title)
    expect(page).to_not have_content(victoria_vacancy.job_title)
  end
end
