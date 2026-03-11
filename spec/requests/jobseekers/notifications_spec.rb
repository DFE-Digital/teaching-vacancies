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

        it "does not automatically mark notifications as read" do
          notification = jobseeker.notifications.first
          expect { get jobseekers_notifications_path }.not_to change { notification.reload.read_at }.from(nil)
        end
      end

      context "without notifications" do
        it "renders the index page without errors" do
          expect(get(jobseekers_notifications_path)).to render_template(:index)
        end
      end
    end

    context "when clicking a link in a notification" do
      before do
        create(:publisher_message, conversation:)
        sign_in(jobseeker, scope: :jobseeker)
      end

      after { sign_out(jobseeker) }

      it "marks that notification as read when visiting the linked page" do
        notification = jobseeker.notifications.first
        freeze_time do
          expect {
            get jobseekers_job_application_path(job_application, tab: "messages", notification_id: notification.id)
          }.to change { notification.reload.read_at }.from(nil).to(Time.current)
        end
      end
    end

    context "when marking all notifications on current page as read" do
      before do
        3.times do
          create(:publisher_message, conversation:)
        end
        sign_in(jobseeker, scope: :jobseeker)
      end

      after { sign_out(jobseeker) }

      it "marks all notifications on the current page as read and redirects back" do
        freeze_time do
          expect {
            patch mark_all_as_read_jobseekers_notifications_path
          }.to change { jobseeker.notifications.unread.count }.from(3).to(0)
        end
        expect(response).to redirect_to(jobseekers_notifications_path)
      end

      context "when notifications span more than one page" do
        before do
          # Create 28 notifications because we show 30 per page and want them to be across 2 pages to test this (and we already have 3)
          28.times do
            create(:publisher_message, conversation:)
          end
        end

        it "only marks notifications on the current page as read" do
          # Page 1 has 30 notifications (NOTIFICATIONS_PER_PAGE), so marking all on page 1 should leave 1 unread (on page 2)
          patch mark_all_as_read_jobseekers_notifications_path
          expect(jobseeker.notifications.unread.count).to eq(1)
        end

        it "only marks notifications on page 2 as read when on page 2" do
          # Page 2 has 1 notification, so marking all on page 2 should leave 30 unread (on page 1)
          patch mark_all_as_read_jobseekers_notifications_path(page: 2)
          expect(jobseeker.notifications.unread.count).to eq(30)
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
