require "rails_helper"

RSpec.describe "Publisher account management" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school, publishers: [publisher]) }

  RSpec.shared_context "with a signed in publisher" do
    before do
      sign_in(publisher, scope: :publisher)
      allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation) # rubocop:disable RSpec/AnyInstance
    end

    after { sign_out(publisher) }
  end

  describe "Unsubscribing from expired vacancy feedback prompt emails" do
    describe "GET #confirm_unsubscribe" do
      context "when the publisher is signed in" do
        include_context "with a signed in publisher"

        it "renders the confirmation page" do
          get confirm_unsubscribe_publishers_account_path(publisher_id: publisher.signed_id)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Are you sure you want to unsubscribe?")
        end
      end
    end
  end

  describe "Opting out from email communications" do
    describe "GET #confirm_email_opt_out" do
      context "when the publisher is signed in" do
        include_context "with a signed in publisher"

        it "renders the confirmation page" do
          get confirm_email_opt_out_publishers_account_path(publisher_id: publisher.signed_id)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Are you sure you want to opt out from service email communications?")
        end
      end

      context "when the publisher is not signed in" do
        before { sign_out(publisher) }

        it "renders the confirmation page" do
          get confirm_email_opt_out_publishers_account_path(publisher_id: publisher.signed_id)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include("Are you sure you want to opt out from service email communications?")
        end
      end

      context "when providing an invalid publisher ID" do
        it "shows a not found error page" do
          get confirm_email_opt_out_publishers_account_path(publisher_id: "invalid_id")
          expect(response).to have_http_status(:not_found)
          expect(response.body).to include("Page not found")
        end
      end
    end

    describe "PATCH #email_opt_out" do
      let(:publisher) { create(:publisher) }

      context "when the publisher is signed in" do
        include_context "with a signed in publisher"

        it "sets the email_opt_out attribute to true" do
          expect {
            patch email_opt_out_publishers_account_path(publisher_id: publisher.signed_id)
          }.to change { publisher.reload.email_opt_out }.from(false).to(true)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have now opted out")
        end
      end

      context "when the publisher is not signed in" do
        before { sign_out(publisher) }

        it "sets the email_opt_out attribute to true" do
          expect {
            patch email_opt_out_publishers_account_path(publisher_id: publisher.signed_id)
          }.to change { publisher.reload.email_opt_out }.from(false).to(true)

          expect(response).to have_http_status(:ok)
          expect(response.body).to include("You have now opted out")
        end
      end

      context "when providing an invalid publisher ID" do
        it "shows a not found error page instead of setting the attribute" do
          expect {
            patch email_opt_out_publishers_account_path(publisher_id: "invalid_id")
          }.not_to(change { publisher.reload.email_opt_out })

          expect(response).to have_http_status(:not_found)
          expect(response.body).to include("Page not found")
        end
      end
    end
  end
end
