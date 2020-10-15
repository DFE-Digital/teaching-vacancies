require 'rails_helper'

RSpec.describe 'Schools in your trust' do
  let(:school_group) { create(:trust) }
  let(:school_1) { create(:school) }
  let(:school_2) { create(:school) }
  let(:school_3) { create(:school) }

  before do
    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_3.id, school_group_id: school_group.id)

    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true

    stub_authentication_step(school_urn: nil, school_group_uid: school_group.uid)
    stub_authorisation_step
    stub_sign_in_with_multiple_organisations

    visit root_path
    sign_in_user
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  scenario 'it allows trust users to manage the schools and trust details' do
    visit organisation_schools_path

    expect(page).to have_content(I18n.t('hiring_staff.organisations.schools.index.title'))
    expect(page).to have_content(school_group.name)
    expect(page)
      .to have_content(I18n.t('hiring_staff.organisations.schools.index.schools', count: school_group.schools.count))

    visit edit_organisation_school_path(school_group, school_group: true)

    expect(page).to have_content(school_group.name)

    fill_in 'organisation_form[description]', with: 'New description of the trust'
    fill_in 'organisation_form[website]', with: 'https://www.this-is-a-test-url.tvs'
    click_button I18n.t('buttons.save_changes')

    expect(page).to have_content('New description of the trust')
    expect(page).to have_content("Details updated for #{school_group.name}")
    expect(page).to have_content('https://www.this-is-a-test-url.tvs')
    expect(page.current_path).to eql(organisation_schools_path)

    visit edit_organisation_school_path(school_1)

    fill_in 'organisation_form[description]', with: 'New description of the school'
    fill_in 'organisation_form[website]', with: 'https://www.this-is-a-test-url.tvs'
    click_button I18n.t('buttons.save_changes')

    expect(page).to have_content('New description of the school')
    expect(page).to have_content('https://www.this-is-a-test-url.tvs')
    expect(page).to have_content("Details updated for #{school_1.name}")
    expect(page.current_path).to eql(organisation_schools_path)
  end
end
