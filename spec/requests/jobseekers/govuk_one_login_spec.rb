require "rails_helper"

RSpec.describe "Govuk One Login authentication response" do
  describe "GET #openid_connect" do
    let(:govuk_one_login_user) do
      instance_double(Jobseekers::GovukOneLogin::User,
                      id: "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4",
                      email: "user@example.com",
                      id_token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6I")
    end
    before do
      get root_path # Loads OneLogin Sign-in button and sets session values for user.
    end

    it "redirects unsuccessful OneLogin responses to the root path with an error message" do
      allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:call)
        .and_raise(Jobseekers::GovukOneLogin::Errors::GovukOneLoginError)

      get jobseeker_openid_connect_omniauth_callback_path
      expect(response).to redirect_to(root_path)
      expect(response.request.flash[:alert]).to include("There was a problem signing in. Please try again.")
    end

    context "when the OneLogin response is successful" do
      before do
        allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:call).and_return(govuk_one_login_user)
      end

      it "redirects the signed in user to their applications page" do
        get jobseeker_openid_connect_omniauth_callback_path

        expect(controller.current_jobseeker).to be_present
        expect(response).to redirect_to(jobseekers_job_applications_path)
      end

      it "sets the OneLogin ID token in the session and deletes the OneLogin state and nonce used for authentication" do
        get jobseeker_openid_connect_omniauth_callback_path

        expect(session[:govuk_one_login_id_token]).to eq(govuk_one_login_user.id_token)
        expect(session[:govuk_one_login_state]).to be_nil
        expect(session[:govuk_one_login_nonce]).to be_nil
      end

      context "when the OneLogin user matches a TV jobseeker" do
        let!(:jobseeker) { create(:jobseeker, email: "user@example.com") }

        it "signs in the user as the existing jobseeker" do
          expect { get jobseeker_openid_connect_omniauth_callback_path }.not_to change(Jobseeker, :count)
          expect(controller.current_jobseeker).to eq(jobseeker)
          expect(controller.current_jobseeker).to have_attributes(email: govuk_one_login_user.email,
                                                                  govuk_one_login_id: govuk_one_login_user.id)
        end
      end

      context "when the OneLogin user does not match a TV jobseeker" do
        it "creates a new jobseeker and signs them in" do
          expect { get jobseeker_openid_connect_omniauth_callback_path }.to change(Jobseeker, :count).by(1)
          expect(controller.current_jobseeker).to eq(Jobseeker.last)
          expect(controller.current_jobseeker).to have_attributes(email: govuk_one_login_user.email,
                                                                  govuk_one_login_id: govuk_one_login_user.id)
        end
      end
    end
  end
end
