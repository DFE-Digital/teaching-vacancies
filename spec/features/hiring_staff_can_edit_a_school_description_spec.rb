require 'rails_helper'
RSpec.feature 'Editing a School’s description' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  scenario 'updating a description' do
    visit organisation_path

    expect(page).to have_content(school.name)
    expect(page).to have_content(school.description)

    click_on 'Change description'
    fill_in 'Description', with: 'Our school prides itself on excellence.'
    click_on 'Save'

    expect(page).to have_content('Our school prides itself on excellence.')
  end

  scenario 'removing a description' do
    visit organisation_path

    expect(page).to have_content(school.name)
    expect(page).to have_content(school.description)

    click_on 'Change description'
    fill_in 'Description', with: ''
    click_on 'Save'

    expect(page).to have_content('Description Not provided')
  end

  scenario 'audits changes to the school\'s description' do
    description = school.description
    visit organisation_path

    click_on 'Change description'
    fill_in 'Description', with: ''
    click_on 'Save'

    activity = school.activities.last
    expect(activity.session_id).to eq(session_id)
    expect(activity.key).to eq('school.update')
    expect(activity.parameters.symbolize_keys).to eq(description: [description, ''])
  end
end
