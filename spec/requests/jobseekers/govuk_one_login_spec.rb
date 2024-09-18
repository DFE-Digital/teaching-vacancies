require "rails_helper"

RSpec.describe "Govuk One Login authentication response" do
  describe "GET #openid_connect" do
    let(:devise_stored_location) { nil }
    let(:govuk_one_login_user) do
      instance_double(Jobseekers::GovukOneLogin::User,
                      id: "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4",
                      email: "user@someemail.com",
                      id_token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6I")
    end

    before do
      allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:call).and_return(govuk_one_login_user)
      allow_any_instance_of(ApplicationController).to receive(:stored_location_for).and_return(devise_stored_location)
      get root_path # Loads OneLogin Sign-in button and sets session values for user.
    end

    it "redirects unsuccessful OneLogin responses to the root path with an error message" do
      allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:call)
        .and_raise(Jobseekers::GovukOneLogin::Errors::GovukOneLoginError)

      get auth_govuk_one_login_callback_path
      expect(response).to redirect_to(root_path)
      expect(response.request.flash[:alert]).to include("There was a problem signing in. Please try again.")
    end

    it "sets the OneLogin ID token in the user session" do
      get auth_govuk_one_login_callback_path

      expect(session[:govuk_one_login_id_token]).to eq(govuk_one_login_user.id_token)
    end

    it " deletes the OneLogin state and nonce used for authentication from the user session" do
      get auth_govuk_one_login_callback_path

      expect(session[:govuk_one_login_state]).to be_nil
      expect(session[:govuk_one_login_nonce]).to be_nil
    end

    context "when the OneLogin user matches a TV jobseeker" do
      let!(:jobseeker) { create(:jobseeker, email: "user@someemail.com") }

      it "signs in the user as the existing jobseeker" do
        expect { get auth_govuk_one_login_callback_path }.not_to change(Jobseeker, :count)
        expect(controller.current_jobseeker).to eq(jobseeker)
        expect(controller.current_jobseeker).to have_attributes(email: govuk_one_login_user.email,
                                                                govuk_one_login_id: govuk_one_login_user.id)
      end

      context "with a quick apply url location to redirect to in devise session" do
        let(:devise_stored_location) { "/job_application/new" }

        it "redirects the jobseeker to the quick apply url" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(devise_stored_location)
        end
      end

      context "with no quick apply url location to redirect to in devise session" do
        let(:devise_stored_location) { jobseekers_subscriptions_path }

        context "when the jobseeker is signing in for the first time via OneLogin" do
          it "redirects the new jobseeker to the account found page" do
            get auth_govuk_one_login_callback_path

            expect(response).to redirect_to(account_found_jobseekers_account_path)
          end
        end

        context "when is not the first time the jobseeker is signing in via OneLogin" do
          let!(:jobseeker) { create(:jobseeker, email: "user@someemail.com", govuk_one_login_id: govuk_one_login_user.id) }

          it "redirects the jobseeker to their applications page" do
            get auth_govuk_one_login_callback_path

            expect(response).to redirect_to(jobseekers_job_applications_path)
          end
        end
      end
    end

    context "when the OneLogin user does not match a TV jobseeker" do
      it "creates a new jobseeker and signs them in" do
        expect { get auth_govuk_one_login_callback_path }.to change(Jobseeker, :count).by(1)
        expect(controller.current_jobseeker).to eq(Jobseeker.last)
        expect(controller.current_jobseeker).to have_attributes(email: govuk_one_login_user.email,
                                                                govuk_one_login_id: govuk_one_login_user.id)
      end

      context "with a quick apply url location to redirect to in devise session" do
        let(:devise_stored_location) { "/job_application/new" }

        it "redirects the jobseeker to the stored location" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(devise_stored_location)
        end
      end

      context "with no quick apply url location to redirect to in devise session" do
        let(:devise_stored_location) { jobseekers_subscriptions_path }

        it "redirects the jobseeker to an account not found page page" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(account_not_found_jobseekers_account_path)
        end
      end
    end
  end
end
