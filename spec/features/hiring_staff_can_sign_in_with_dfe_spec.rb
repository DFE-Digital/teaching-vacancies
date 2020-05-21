require 'rails_helper'
require 'message_encryptor'

RSpec.shared_examples 'a successful sign in' do
  scenario 'it signs in the user successfully' do
    expect(page).to have_content("Jobs at #{school.name}")
    within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.sign_out')) }
    within('.govuk-header__navigation') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
  end

  scenario 'adds entries in the audit log' do
    activity = PublicActivity::Activity.last
    expect(activity.key).to eq('dfe-sign-in.authorisation.success')
    expect(activity.trackable.urn).to eq(school.urn)

    authorisation = PublicActivity::Activity.last
    expect(authorisation.key).to eq('dfe-sign-in.authorisation.success')
    expect(authorisation.trackable.urn).to eq(school.urn)
  end

  scenario 'updates the user record with the DfE Sign In email address' do
    user_record = User.find_by(oid: user_oid)
    expect(user_record.email).to eq(dsi_email_address)
  end
end

RSpec.shared_examples 'a failed sign in' do |options|
  scenario 'it does not sign-in the user, and tells the user what to do' do
    visit root_path

    sign_in_user

    expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
    expect(page).to have_content(options[:email])
    within('.govuk-header__navigation') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
  end

  scenario 'adds entries in the audit log' do
    visit root_path

    sign_in_user

    authentication = PublicActivity::Activity.first
    expect(authentication.key).to eq('dfe-sign-in.authentication.success')

    authorisation = PublicActivity::Activity.last
    expect(authorisation.key).to eq('dfe-sign-in.authorisation.failure')
  end

  scenario 'logs a partially anonymised identifier so we can lookup any legitimate users who may be genuinley stuck' do
    expect(Rails.logger)
      .to receive(:warn)
      .with("Hiring staff signed in: #{options[:user_id]}")

    expect(Rails.logger)
      .to receive(:warn)
      .with("Hiring staff not authorised: #{options[:user_id]} for school: #{options[:school_urn]}")

    visit root_path

    sign_in_user
  end
end

RSpec.feature 'Hiring staff signing-in with DfE Sign In' do
  let(:user_oid) { '161d1f6a-44f1-4a1a-940d-d1088c439da7' }
  let(:dsi_email_address) { Faker::Internet.email }

  before(:each) do
    stub_accepted_terms_and_condition
    OmniAuth.config.test_mode = true
    allow(AuthenticationFallback).to receive(:enabled?) { false }
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context 'with valid credentials that match a school' do
    let!(:school) { create(:school, urn: '110627') }

    before(:each) do
      stub_authentication_step email: dsi_email_address
      stub_authorisation_step
      stub_sign_in_with_multiple_organisations

      visit root_path

      sign_in_user
    end

    it_behaves_like 'a successful sign in'

    scenario 'it redirects the sign in page to the school page' do
      visit new_identifications_path
      expect(page).to have_content("Jobs at #{school.name}")
      expect(current_path).to eql(school_path)
    end

    context 'the user can switch between organisations' do
      let!(:other_school) { create(:school, urn: '101010') }

      scenario 'allows the user to switch between organisations' do
        expect(page).to have_content("Jobs at #{school.name}")

        # Mock switching organisations from within DfE Sign In
        stub_authentication_step(
          organisation_id: 'E8C509A2-3AD8-485C-957F-BEE7047FDA8D',
          school_urn: '101010'
        )
        stub_authorisation_step(organisation_id: 'E8C509A2-3AD8-485C-957F-BEE7047FDA8D',
                                fixture_file: 'dfe_sign_in_authorisation_for_different_org_response.json')

        click_on 'Change organisation'
        expect(page).to have_content("Jobs at #{other_school.name}")
      end
    end
  end

  context 'with valid credentials but no authorisation' do
    before(:each) do
      stub_authentication_step(email: 'another_email@example.com')
      stub_authorisation_step_with_not_found
    end

    it_behaves_like 'a failed sign in', user_id: '161d1f6a-44f1-4a1a-940d-d1088c439da7',
                                        school_urn: '110627',
                                        email: 'another_email@example.com'
  end

  context 'when there is was an error with DfE Sign-in' do
    before(:each) do
      stub_authentication_step
      stub_authorisation_step_with_external_error
    end

    it 'raises an error' do
      visit root_path

      expect { sign_in_user }.to raise_error(Authorisation::ExternalServerError)
    end
  end

  def sign_in_user
    within('.govuk-header__navigation.mobile-header-top-border') { click_on(I18n.t('nav.sign_in')) }
    click_on(I18n.t('sign_in.link'))
  end

  def stub_accepted_terms_and_condition
    create(:user, oid: '161d1f6a-44f1-4a1a-940d-d1088c439da7', accepted_terms_at: 1.day.ago)
  end
end
