require 'rails_helper'

RSpec.describe 'Hiring staff can set managed organisations user preferences' do
  let(:school_group) { create(:trust) }
  let(:school_1) { create(:school, name: 'Happy Rainbows School') }
  let(:school_2) { create(:school, name: 'Dreary Grey School') }
  let(:user_preference) { UserPreference.last }

  before do
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
    visit organisation_managed_organisations_path

    expect(page).to have_content(
      I18n.t('hiring_staff.managed_organisations.panel.title', organisation: school_group.name),
    )

    check I18n.t('hiring_staff.managed_organisations.options.school_group'),
          name: 'managed_organisations_form[managed_school_ids][]', visible: false
    check school_1.name, name: 'managed_organisations_form[managed_school_ids][]', visible: false

    click_on I18n.t('buttons.continue')

    expect(page.current_path).to eql(organisation_path)
    expect(user_preference.managed_school_ids).to eql([school_group.id, school_1.id])
  end

  scenario 'it allows school group users to select to manage all jobs' do
    visit organisation_managed_organisations_path

    expect(page).to have_content(
      I18n.t('hiring_staff.managed_organisations.panel.title', organisation: school_group.name),
    )

    check I18n.t('hiring_staff.managed_organisations.options.all'),
          name: 'managed_organisations_form[managed_organisations][]', visible: false
    check school_1.name, name: 'managed_organisations_form[managed_school_ids][]', visible: false

    click_on I18n.t('buttons.continue')

    expect(page.current_path).to eql(organisation_path)
    expect(user_preference.managed_organisations).to eql('all')
    expect(user_preference.managed_school_ids).to eql([])
  end
end
