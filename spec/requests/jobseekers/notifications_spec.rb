require "rails_helper"

RSpec.describe "Jobseeker notifications" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy) }
  let(:job_application) { create(:job_application, jobseeker:, vacancy:) }
  let(:conversation) { create(:conversation, job_application:) }

  describe "GET #index" do
    context "when signed in" do
      before do
        sign_in(jobseeker, scope: :jobseeker)
      end

      after { sign_out(jobseeker) }

      context "with notifications present" do
        before do
          create(:publisher_message, conversation:)
        end

        it "renders the index page" do
          expect(get(jobseekers_notifications_path)).to render_template(:index)
        end

        it "marks notifications as read" do
          notification = jobseeker.notifications.first
          freeze_time do
            expect { get jobseekers_notifications_path }.to change { notification.reload.read_at }.from(nil).to(Time.current)
          end
        end
      end

      context "without notifications" do
        it "renders the index page without errors" do
          expect(get(jobseekers_notifications_path)).to render_template(:index)
        end
      end
    end

    context "when signed out" do
      it "redirects to the jobseeker sign in page" do
        get jobseekers_notifications_path
        expect(response).to redirect_to(new_jobseeker_session_path(redirected: true))
      end
    end
  end
end
