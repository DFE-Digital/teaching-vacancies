require "rails_helper"
require "dfe/analytics/rspec/matchers"

RSpec.describe "Govuk One Login authentication response" do
  describe "GET #openid_connect" do
    let(:devise_stored_location) { nil }
    let(:govuk_one_login_user) do
      instance_double(Jobseekers::GovukOneLogin::User,
                      id: "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4",
                      email: "user@contoso.com",
                      id_token: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjFlOWdkazcifQ.ewogImlzcyI6I")
    end

    RSpec.shared_examples "post sign-in redirections" do
      context "with a quick apply url location to redirect to in devise session" do
        let(:devise_stored_location) { "/job_application/new" }

        it "redirects the jobseeker to the quick apply url" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(devise_stored_location)
        end
      end

      context "with a peak times unsubscribe url location to redirect to in devise session" do
        let(:devise_stored_location) { edit_jobseekers_account_email_preferences_path }

        it "redirects the jobseeker to the email preferences page" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(devise_stored_location)
        end
      end

      context "with the job alerts subscriptions page to redirect to in devise session" do
        let(:devise_stored_location) { jobseekers_subscriptions_path }

        it "redirects the jobseeker to the job alerts subscriptions page" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(devise_stored_location)
        end
      end

      context "with a saving/unsaving job action to redirect to in devise session" do
        let(:vacancy) { create(:vacancy) }
        let(:devise_stored_location) { new_jobseekers_saved_job_path(vacancy) }

        it "redirects the jobseeker to the job page page" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(devise_stored_location)
        end
      end
    end

    before do
      allow_any_instance_of(ApplicationController).to receive(:stored_location_for).and_return(devise_stored_location)
      allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:call).and_return(govuk_one_login_user)
      get root_path # Loads OneLogin Sign-in button and sets session values for user.
    end

    context "when the OneLogin response is a failure" do
      before do
        allow(Jobseekers::GovukOneLogin::UserFromAuthResponse).to receive(:call)
          .and_raise(Jobseekers::GovukOneLogin::Errors::GovukOneLoginError)
      end

      it "redirects the unsigned jobseeker to the root path with an error message" do
        get auth_govuk_one_login_callback_path

        expect(response).to redirect_to(root_path)
        expect(response.request.flash[:alert])
          .to include(I18n.t("jobseekers.govuk_one_login_callbacks.openid_connect.error"))
      end

      it "sends an analytics event for a failed OneLogin sign-in attempt", :dfe_analytics do
        get auth_govuk_one_login_callback_path

        expect(:jobseeker_failed_govuk_one_login_sign_in).to have_been_enqueued_as_analytics_event
      end
    end

    it "sets the OneLogin ID token in the user session" do
      get auth_govuk_one_login_callback_path

      expect(session[:govuk_one_login_id_token]).to eq(govuk_one_login_user.id_token)
    end

    it "deletes the OneLogin state and nonce used for authentication from the user session" do
      get auth_govuk_one_login_callback_path

      expect(session[:govuk_one_login_state]).to be_nil
      expect(session[:govuk_one_login_nonce]).to be_nil
    end

    it "sends an analytics event for a successful OneLogin sign-in attempt", :dfe_analytics do
      get auth_govuk_one_login_callback_path

      expect(:jobseeker_successful_govuk_one_login_sign_in).to have_been_enqueued_as_analytics_event
    end

    context "when the OneLogin user does not match a TV jobseeker" do
      it_behaves_like "post sign-in redirections"

      it "creates a new jobseeker and signs them in" do
        expect { get auth_govuk_one_login_callback_path }.to change(Jobseeker, :count).by(1)
        expect(controller.current_jobseeker).to eq(Jobseeker.last)
        expect(controller.current_jobseeker).to have_attributes(email: govuk_one_login_user.email,
                                                                govuk_one_login_id: govuk_one_login_user.id)
      end

      context "with no explicitly allowed url location to redirect to in devise session" do
        let(:devise_stored_location) { jobseeker_root_path }

        it "redirects the jobseeker to an account not found page page" do
          get auth_govuk_one_login_callback_path

          expect(response).to redirect_to(account_not_found_jobseekers_account_path)
        end
      end
    end

    context "when the OneLogin user matches a TV jobseeker" do
      before do
        allow(govuk_one_login_user).to receive(:id).and_return(jobseeker.govuk_one_login_id)
      end

      let!(:jobseeker) { create(:jobseeker, email: govuk_one_login_user.email) }

      it_behaves_like "post sign-in redirections"

      it "signs in the user as the existing jobseeker" do
        expect { get auth_govuk_one_login_callback_path }.not_to change(Jobseeker, :count)
        expect(controller.current_jobseeker).to eq(jobseeker)
        expect(controller.current_jobseeker).to have_attributes(email: govuk_one_login_user.email,
                                                                govuk_one_login_id: govuk_one_login_user.id)
      end

      context "when the jobseeker is signing in for the first time via OneLogin" do
        let!(:jobseeker) { create(:jobseeker, email: govuk_one_login_user.email, govuk_one_login_id: nil) }

        before do
          allow(govuk_one_login_user).to receive(:id).and_return("urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4")
        end

        it "sets the jobseeker's OneLogin ID in the existing teaching vacancies jobseeker" do
          expect { get auth_govuk_one_login_callback_path }
            .to change { jobseeker.reload.govuk_one_login_id }.from(nil).to(govuk_one_login_user.id)
        end

        context "with no explicitly allowed url location to redirect to in devise session" do
          let(:devise_stored_location) { jobseeker_root_path }

          it "redirects the new jobseeker to the account found page" do
            get auth_govuk_one_login_callback_path

            expect(response).to redirect_to(account_found_jobseekers_account_path)
          end
        end
      end

      context "when is not the first time the jobseeker is signing in via OneLogin" do
        let(:jobseeker) { create(:jobseeker, email: govuk_one_login_user.email, govuk_one_login_id: govuk_one_login_user.id) }

        context "with no explicitly allowed url location to redirect to in devise session" do
          let(:devise_stored_location) { jobseeker_root_path }

          it "redirects the jobseeker to their applications page" do
            get auth_govuk_one_login_callback_path

            expect(response).to redirect_to(jobseekers_job_applications_path)
          end
        end
      end

      context "when the jobseeker got their account deleted and re-created in OneLogin" do
        let(:original_one_login_id) { "urn:fdc:gov.uk:2022:FctZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlmN3" }
        let(:new_one_login_id) { "urn:fdc:gov.uk:2022:VtcZjnU4Sif2oyJZola3OkN0e3Jeku1cIMN38rFlhU4" }
        let!(:jobseeker) do
          create(:jobseeker, email: govuk_one_login_user.email, govuk_one_login_id: original_one_login_id)
        end

        before do
          allow(govuk_one_login_user).to receive(:id).and_return(new_one_login_id)
        end

        it "updates the jobseeker's OneLogin ID in the existing teaching vacancies jobseeker" do
          expect { get auth_govuk_one_login_callback_path }
            .to change { jobseeker.reload.govuk_one_login_id }.from(original_one_login_id).to(new_one_login_id)
        end

        context "with no explicitly allowed url location to redirect to in devise session" do
          let(:devise_stored_location) { jobseeker_root_path }

          it "redirects the jobseeker to their applications page" do
            get auth_govuk_one_login_callback_path

            expect(response).to redirect_to(jobseekers_job_applications_path)
          end
        end
      end

      context "when the jobseeker has updated their email in OneLogin" do
        let!(:jobseeker) do
          create(:jobseeker, email: "original_email@contoso.com", govuk_one_login_id: govuk_one_login_user.id)
        end

        context "when the updated email does not match any other jobseeker in teaching vacancies" do
          it "updates the new email in the existing teaching vacancies jobseeker" do
            expect { get auth_govuk_one_login_callback_path }
              .to change { jobseeker.reload.email }.from("original_email@contoso.com").to(govuk_one_login_user.email)
          end

          it "redirects the jobseeker to their applications page" do
            get auth_govuk_one_login_callback_path

            expect(response).to redirect_to(jobseekers_job_applications_path)
          end
        end

        context "when the updated email matches a different jobseeker account in teaching vacancies" do
          let!(:legacy_jobseeker) do
            create(:jobseeker, email: govuk_one_login_user.email, govuk_one_login_id: nil)
          end
          let!(:legacy_jobseeker_application) { create(:job_application, jobseeker: legacy_jobseeker) }

          context "when the jobseeker to sign in had already some saved data" do
            before { create(:job_application, jobseeker: jobseeker) }

            it "doesn't update the jobseeker email" do
              expect { get auth_govuk_one_login_callback_path }.not_to(change { jobseeker.reload.email })
            end

            it "doesn't transfer the legacy jobseeker's applications to the current jobseeker" do
              expect { get auth_govuk_one_login_callback_path }.not_to(change { jobseeker.job_applications.count })
            end

            it "doesn't delete the legacy jobseeker" do
              expect { get auth_govuk_one_login_callback_path }.not_to change(Jobseeker, :count)
            end

            it "redirects the jobseeker to their applications page" do
              get auth_govuk_one_login_callback_path

              expect(response).to redirect_to(jobseekers_job_applications_path)
            end
          end

          context "when the jobseeker to sign in had no saved data" do
            it "updates the jobseeker email" do
              expect { get auth_govuk_one_login_callback_path }
                .to change { jobseeker.reload.email }.from(jobseeker.email).to(govuk_one_login_user.email)
            end

            it "transfers the legacy jobseeker's applications to the current jobseeker" do
              expect { get auth_govuk_one_login_callback_path }
                .to change { jobseeker.reload.job_applications }.from([]).to([legacy_jobseeker_application])
            end

            it "deletes the legacy jobseeker" do
              expect { get auth_govuk_one_login_callback_path }.to change(Jobseeker, :count).by(-1)
              expect { legacy_jobseeker.reload }.to raise_error(ActiveRecord::RecordNotFound)
            end

            it "redirects the jobseeker to their applications page" do
              get auth_govuk_one_login_callback_path

              expect(response).to redirect_to(jobseekers_job_applications_path)
            end
          end
        end
      end
    end
  end
end
