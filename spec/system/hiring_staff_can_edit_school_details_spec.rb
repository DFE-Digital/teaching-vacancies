require 'rails_helper'

RSpec.describe 'Editing a School’s details' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  scenario 'it allows school users to edit the school details' do
    visit organisation_path

    expect(page).to have_content(school.name)
    expect(page).to have_content(school.description)
    expect(page).to have_content(school.url)

    click_on 'Change school description'
    expect(find_field('organisation_form[website]').value).to eql(school.url)
    fill_in 'organisation_form[description]', with: 'Our school prides itself on excellence.'
    fill_in 'organisation_form[website]', with: 'https://www.this-is-a-test-url.tvs'
    click_on I18n.t('buttons.save_changes')

    expect(page).to have_content('Our school prides itself on excellence.')
    expect(page).to have_content('https://www.this-is-a-test-url.tvs')
    expect(page).to have_content("Details updated for #{school.name}")
    expect(page.current_path).to eql(organisation_path)
  end
end
