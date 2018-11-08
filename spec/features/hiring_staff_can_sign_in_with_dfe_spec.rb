require 'rails_helper'
require 'message_encryptor'

RSpec.shared_examples 'a successful sign in' do
  scenario 'it signs in the user successfully' do
    expect(page).to have_content("Jobs at #{school.name}")
    within('.app-navigation') { expect(page).to have_content(I18n.t('nav.sign_out')) }
    within('.app-navigation') { expect(page).to have_content(I18n.t('nav.school_page_link')) }
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
  scenario 'it does not sign-in the user, and tells the user what to do' do
    visit root_path

    click_on(I18n.t('nav.sign_in'))
    click_on(I18n.t('sign_in.link'))

    expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
    expect(page).to have_content(options['email'])
    within('.app-navigation') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
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

  scenario 'triggers a job to log the failed audit to a Spreadsheet' do
    visit root_path
    timestamp = Time.zone.now.iso8601

    failed_authorisation = [timestamp.to_s, 'an-unknown-oid', options[:school_urn], options[:email],
                            'failed_authorisation']

    encrypted_failed_authorisation = MessageEncryptor.new(failed_authorisation).encrypt
    authorisation_encryptor = double(MessageEncryptor,
                                     encrypt: encrypted_failed_authorisation)

    expect(MessageEncryptor).to receive(:new).with(failed_authorisation)
                                             .and_return(authorisation_encryptor)
    expect(AuditSignInEventJob).to receive(:perform_later)
      .with(encrypted_failed_authorisation)

    Timecop.freeze(timestamp) do
      click_on(I18n.t('nav.sign_in'))
      click_on(I18n.t('sign_in.link'))
    end
  end

  scenario 'logs a partially anonymised identifier so we can lookup any legitimate users who may be genuinley stuck' do
    expect(Rails.logger)
      .to receive(:warn)
      .with("Hiring staff signed in: #{options[:dsi_id]}")

    expect(Rails.logger)
      .to receive(:warn)
      .with("Hiring staff not authorised: #{options[:dsi_id]} for school: #{options[:school_urn]}")

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
    end

    context 'sign in audit' do
      scenario 'triggers a job to log the failed audit to a Spreadsheet' do
        visit root_path
        timestamp = Time.zone.now.iso8601
        successful_authorisation = [timestamp.to_s,
                                    'an-unknown-oid',
                                    school.urn,
                                    'an-email@example.com',
                                    'successful_authorisation']

        encrypted_successful_authorisation = MessageEncryptor.new(successful_authorisation).encrypt
        authorisation_encryptor = double(MessageEncryptor,
                                         encrypt: encrypted_successful_authorisation)

        expect(MessageEncryptor).to receive(:new).with(successful_authorisation)
                                                 .and_return(authorisation_encryptor)
        expect(AuditSignInEventJob).to receive(:perform_later).with(encrypted_successful_authorisation)

        Timecop.freeze(timestamp) do
          click_on(I18n.t('nav.sign_in'))
          click_on(I18n.t('sign_in.link'))
        end
      end
    end

    context 'successful events' do
      before(:each) do
        visit root_path
        click_on(I18n.t('nav.sign_in'))
        click_on(I18n.t('sign_in.link'))
      end

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

    it_behaves_like 'a failed sign in', dsi_id: 'an-unknown-oid',
                                        school_urn: '110627',
                                        email: 'another_email@example.com'
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

    it_behaves_like 'a failed sign in', dsi_id: 'an-unknown-oid',
                                        school_urn: '',
                                        email: 'an-email@example.com'
  end
end
