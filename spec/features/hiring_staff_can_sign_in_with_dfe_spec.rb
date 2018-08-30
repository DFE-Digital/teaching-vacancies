require 'rails_helper'

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
end

RSpec.shared_examples 'a failed sign in' do |options|
  scenario 'it does not sign-in the user' do
    visit root_path

    click_on(I18n.t('nav.sign_in'))
    click_on(I18n.t('sign_in.link'))

    expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
    within('.govuk-header__navigation') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
  end

  scenario 'adds entries in the audit log' do
    visit root_path

    click_on(I18n.t('nav.sign_in'))
    click_on(I18n.t('sign_in.link'))

    authentication = PublicActivity::Activity.first
    expect(authentication.key).to eq('dfe-sign-in.authentication.success')

    authorisation = PublicActivity::Activity.last
    expect(authorisation.key).to eq('dfe-sign-in.authorisation.failure')
  end

  scenario 'logs a partially anonymised identifier so we can lookup any legitimate users who may be genuinley stuck' do
    anonymised_email = options[:email].gsub(/(.)./, '\1*')
    expect_any_instance_of(ActiveSupport::Logger)
      .to receive(:warn)
      .with("Unauthenticated user for identifier: #{anonymised_email}, school_urn: #{options[:school_urn]}")

    visit root_path

    click_on(I18n.t('nav.sign_in'))
    click_on(I18n.t('sign_in.link'))
  end
end

RSpec.feature 'Hiring staff signing-in with DfE Sign In' do
  before(:each) do
    OmniAuth.config.test_mode = true
    ENV['SIGN_IN_WITH_DFE'] = 'true'
  end

  after(:each) do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    ENV['SIGN_IN_WITH_DFE'] = 'false'
    OmniAuth.config.test_mode = false
  end

  let!(:school) { create(:school, urn: '110627') }
  let!(:other_school) { create(:school, urn: '101010') }
  let!(:user) { create(:user, oid: 'an-unknown-oid') }

  context 'with valid credentials that do match a school' do
    before(:each) do
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        provider: 'dfe',
        uid: 'an-unknown-oid',
        info: {
          email: 'an-email@example.com',
        },
        extra: {
          raw_info: {
            organisation: { urn: '110627' }
          }
        }
      )
      expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(mock_permissions)
      visit root_path
      click_on(I18n.t('nav.sign_in'))
      click_on(I18n.t('sign_in.link'))
    end

    let(:mock_response) do
      double(code: '200', body: {
        user:
          {
            permissions:
              [
                {
                  user_token: 'an-email@example.com',
                  school_urn: '110627'
                },
                {
                  user_token: 'an-email@example.com',
                  school_urn: '101010'
                }
              ]
          }
      }.to_json)
    end

    let(:mock_permissions) { AuthHelpers::MockPermissions.new(mock_response) }

    it_behaves_like 'a successful sign in'

    scenario 'it redirects the sign in page to the school page' do
      visit new_identifications_path
      expect(page).to have_content("Jobs at #{school.name}")
      expect(current_path).to eql(school_path)
    end

    context 'the user can switch between organisations' do
      scenario 'allows the user to switch between organisations' do
        expect(page).to have_content("Jobs at #{school.name}")

        # Mock switching organisations on DfE Sign In
        OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
          provider: 'dfe',
          uid: 'an-unknown-oid',
          info: {
            email: 'an-email@example.com',
          },
          extra: {
            raw_info: {
              organisation: { urn: '101010' }
            }
          }
        )
        expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
          .and_return(mock_permissions)
        click_on 'Change organisation'

        expect(page).to have_content("Jobs at #{other_school.name}")
      end
    end
  end

  context 'with valid credentials but no authorisation' do
    before(:each) do
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        provider: 'dfe',
        uid: 'an-unknown-oid',
        info: {
          email: 'another_email@example.com',
        },
        extra: {
          raw_info: {
            organisation: { urn: '110627' }
          }
        }
      )

      mock_authorisation_response = double(code: '200', body: {
        user:
          {
            permissions: []
          }
      }.to_json)

      expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_authorisation_response))
    end

    it_behaves_like 'a failed sign in', email: 'another_email@example.com', school_urn: '110627'
  end

  context 'with valid credentials and no organisation in DfE Sign In but existing permissions' do
    before(:each) do
      OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
        provider: 'dfe',
        uid: 'an-unknown-oid',
        info: {
          email: 'an-email@example.com',
        },
        extra: {
          raw_info: {
            organisation: {}
          }
        }
      )

      mock_authorisation_response = double(code: '200', body: {
        user:
          {
            permissions:
              [
                {
                  user_token: 'an-email@example.com',
                  school_urn: '110627'
                }
              ]
          }
      }.to_json)

      expect(TeacherVacancyAuthorisation::Permissions).to receive(:new)
        .and_return(AuthHelpers::MockPermissions.new(mock_authorisation_response))
    end

    it_behaves_like 'a failed sign in', email: 'an-email@example.com', school_urn: nil
  end
end
