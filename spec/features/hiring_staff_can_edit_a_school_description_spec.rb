require 'rails_helper'
RSpec.feature 'Editing a School’s description' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'updating a description' do
    visit school_path(school.urn)

    expect(page).to have_content(school.name)
    expect(page).to have_content(school.description)

    click_on 'Change description'
    fill_in 'Description', with: 'Our school prides itself on excellence.'
    click_on 'Save'

    expect(page).to have_content('Our school prides itself on excellence.')
  end

  scenario 'removing a description' do
    visit school_path(school.urn)

    expect(page).to have_content(school.name)
    expect(page).to have_content(school.description)

    click_on 'Change description'
    fill_in 'Description', with: ''
    click_on 'Save'

    expect(page).to have_content('Description Not provided')
  end
end
