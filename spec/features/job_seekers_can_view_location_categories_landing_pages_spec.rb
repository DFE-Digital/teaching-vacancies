require 'rails_helper'

RSpec.feature 'Viewing a location category landing page', elasticsearch: true do
  let!(:london_region) { Region.find_or_create_by(name: 'London') }
  let!(:camden_vacancy) do
    create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Camden'))
  end
  let!(:kensington_vacancy_one) do
    create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Kensington and Chelsea'))
  end

  let!(:kensington_vacancy_two) do
    create(:vacancy, :published,
      school: build(:school, region: london_region, local_authority: 'Kensington and Chelsea'))
  end

  before(:each) do
    allow(LocationCategory).to receive(:include?).with('camden').and_return(true)
    allow(LocationCategory).to receive(:include?).with('kensington and chelsea').and_return(true)
    Vacancy.__elasticsearch__.client.indices.flush
  end

  scenario 'only results that fall within the location category are displayed' do
    visit location_category_path('camden')

    expect(page).to have_content(camden_vacancy.job_title)
    expect(page).to_not have_content(kensington_vacancy_one.job_title)
    expect(page).to_not have_content(kensington_vacancy_two.job_title)
  end

  scenario 'a specific heading for the landing page is displayed' do
    visit location_category_path('camden')
    expect(page).to have_content('1 teaching job in Camden.')

    visit location_category_path('kensington and chelsea')
    expect(page).to have_content('2 teaching jobs in Kensington and Chelsea.')
  end

  scenario 'a specific page title for the landing page is displayed' do
    visit location_category_path('camden')

    expect(page).to have_title('Teaching jobs in Camden')
  end

  context 'meta tags' do
    let(:description) { 'Find teaching jobs in Camden on Teaching Vacancies, the free national job site for teachers, with no recruitment fees for schools.' }

    scenario'description' do
      visit location_category_path('camden')
      expect(page).to have_css("meta[name='description'][content=#{description}]", visible: false)
    end
  end
end
