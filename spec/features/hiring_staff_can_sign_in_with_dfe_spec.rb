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

    sign_in_user

    expect(page).to have_content(I18n.t('static_pages.not_authorised.title'))
    expect(page).to have_content(options['email'])
    within('.app-navigation') { expect(page).not_to have_content(I18n.t('nav.school_page_link')) }
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
  context 'when the dfe sign in authorisation feature flag is enabled' do
    before(:each) do
      allow(DfeSignInAuthorisationFeature).to receive(:enabled?) { true }
      stub_accepted_terms_and_condition
      OmniAuth.config.test_mode = true
    end

    after(:each) do
      OmniAuth.config.mock_auth[:default] = nil
      OmniAuth.config.mock_auth[:dfe] = nil
      OmniAuth.config.test_mode = false
    end

    context 'with valid credentials that match a school' do
      let!(:school) { create(:school, urn: '110627') }

      before(:each) do
        stub_authentication_step
        stub_authorisation_step

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
        stub_authentication_step
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

      it 'renders an error page advising of a problem with DSI rather than this service' do
        visit root_path

        sign_in_user

        expect(page).to have_content(I18n.t('error_pages.server_error'))
      end
    end
  end

  context 'when the dfe sign-in authorisation feature flag is disabled' do
    before(:each) do
      allow(DfeSignInAuthorisationFeature).to receive(:enabled?) { false }
      stub_accepted_terms_and_condition
      OmniAuth.config.test_mode = true
    end

    after(:each) do
      OmniAuth.config.mock_auth[:default] = nil
      OmniAuth.config.mock_auth[:dfe] = nil
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

      context 'successful events' do
        before(:each) do
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

      it_behaves_like 'a failed sign in', user_id: 'an-unknown-oid',
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

      it_behaves_like 'a failed sign in', user_id: 'an-unknown-oid',
                                          school_urn: '',
                                          email: 'an-email@example.com'
    end
  end

  def sign_in_user
    click_on(I18n.t('nav.sign_in'))
    click_on(I18n.t('sign_in.link'))
  end

  def stub_accepted_terms_and_condition
    create(:user, oid: '161d1f6a-44f1-4a1a-940d-d1088c439da7', accepted_terms_at: 1.day.ago)
  end
end
