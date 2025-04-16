require "rails_helper"

RSpec.describe "Publishers::Vacancies::ExpiredFeedbacksController" do
  describe "POST /organisation/jobs/:job_id/expired-feedback" do
    let(:valid_publisher) { create(:publisher, :with_organisation) }
    let(:invalid_publisher) { create(:publisher, :with_organisation) }
    let(:vacancy) { create(:vacancy, publisher: valid_publisher) }
    let(:valid_params) do
      {
        publishers_job_listing_expired_feedback_form: {
          hired_status: "hired_other_free",
          listed_elsewhere: "listed_dont_know",
        },
      }
    end

    context "when making a request without a signed id" do
      let(:job_id) { vacancy.id.to_s } # use unsigned ID to force fallback

      context  "when a hiring staff user is logged in" do
        # rubocop:disable RSpec/AnyInstance
        before do
          # Stub authenticate_scope! to simulate a logged-in user
          allow_any_instance_of(Publishers::Vacancies::ExpiredFeedbacksController).to receive(:authenticate_scope!) { vacancy.publisher }
        end
        # rubocop:enable RSpec/AnyInstance

        it "finds the vacancy via fallback and updates it" do
          expect {
            post "/organisation/jobs/#{job_id}/expired-feedback", params: valid_params
          }.to change { vacancy.reload.attributes.slice("hired_status", "listed_elsewhere") }
           .from({ "hired_status" => nil, "listed_elsewhere" => nil })
           .to({ "hired_status" => "hired_other_free", "listed_elsewhere" => "listed_dont_know" })

          expect(response).to redirect_to(submitted_organisation_job_expired_feedback_path)
        end
      end

      context "when a hiring staff user is not logged in" do
        # Do not stub authenticate_scope! so that Devise authentication is enforced
        it "does not update vacancy and redirects to the login page" do
          expect {
            post "/organisation/jobs/#{job_id}/expired-feedback", params: valid_params
          }.not_to(change { vacancy.reload.attributes.slice("hired_status", "listed_elsewhere") })

          expect(response).to redirect_to(new_publisher_session_path(redirected: true))
        end
      end
    end
  end
end
