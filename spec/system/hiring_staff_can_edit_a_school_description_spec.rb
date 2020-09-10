require 'rails_helper'

RSpec.describe 'Editing a School’s description' do
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
    click_on I18n.t('buttons.save_changes')

    expect(page).to have_content('Our school prides itself on excellence.')
    expect(page).to have_content("Description updated for #{school.name}")
    expect(page.current_path).to eql(organisation_path)
  end

  scenario 'removing a description' do
    visit organisation_path

    expect(page).to have_content(school.name)
    expect(page).to have_content(school.description)

    click_on 'Change description'
    fill_in 'Description', with: ''
    click_on I18n.t('buttons.save_changes')

    expect(page).to have_content('Description Not provided')
    expect(page).to have_content("Description updated for #{school.name}")
    expect(page.current_path).to eql(organisation_path)
  end
end
