require 'rails_helper'

RSpec.feature 'Hiring staff can set user preferences' do
  let(:school_group) { create(:school_group) }
  let(:school_1) { create(:school) }
  let(:school_2) { create(:school) }
  let(:user_preference) { UserPreference.last }

  before do
    allow(SchoolGroupJobsFeature).to receive(:enabled?).and_return(true)

    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)

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

  scenario "it allows school group users to select which organisation's jobs they want to manage" do
    visit organisation_user_preference_path

    expect(page).to have_content(I18n.t('hiring_staff.preferences.panel.title', organisation: school_group.name))

    check I18n.t('hiring_staff.preferences.select_organisations_form.options.school_group'),
          name: 'user_preference_form[managed_organisations][]', visible: false
    check school_1.name, name: 'user_preference_form[managed_school_urns][]', visible: false

    click_on I18n.t('buttons.continue')

    expect(page.current_path).to eql(school_group_temporary_path)
    expect(user_preference.managed_organisations).to eql('school_group')
    expect(user_preference.managed_school_urns).to eql([school_1.urn])
  end
end
