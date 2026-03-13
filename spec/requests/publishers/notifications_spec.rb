require "rails_helper"

RSpec.describe "Publisher notifications" do
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  describe "GET #index" do
    context "when signed in" do
      before do
        Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(publisher)
        allow_any_instance_of(Publishers::NotificationsController).to receive(:current_organisation).and_return(organisation)
        sign_in(publisher, scope: :publisher)
      end

      after { sign_out(publisher) }

      it "renders the index page" do
        expect(get(publishers_notifications_path)).to render_template(:index)
      end

      it "does not automatically mark notifications as read" do
        notification = publisher.notifications.first
        expect { get publishers_notifications_path }.not_to change { notification.reload.read_at }.from(nil)
      end
    end

    context "when clicking a link in a notification" do
      before do
        Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(publisher)
        allow_any_instance_of(Publishers::NotificationsController).to receive(:current_organisation).and_return(organisation)
        allow_any_instance_of(Publishers::Vacancies::JobApplications::BaseController).to receive(:current_organisation).and_return(organisation)
        sign_in(publisher, scope: :publisher)
      end

      after { sign_out(publisher) }

      it "marks that notification as read when visiting the linked page" do
        notification = publisher.notifications.first
        freeze_time do
          expect {
            get organisation_job_job_application_path(vacancy.id, job_application.id, notification_id: notification.id)
          }.to change { notification.reload.read_at }.from(nil).to(Time.current)
        end
      end

      it "does not error when notification_id is invalid" do
        expect {
          get organisation_job_job_application_path(vacancy.id, job_application.id, notification_id: "invalid-id")
        }.not_to raise_error
      end
    end

    context "when marking all notifications on current page as read" do
      before do
        3.times do
          Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(publisher)
        end
        allow_any_instance_of(Publishers::NotificationsController).to receive(:current_organisation).and_return(organisation)
        sign_in(publisher, scope: :publisher)
      end

      after { sign_out(publisher) }

      it "marks all notifications on the current page as read and redirects back" do
        freeze_time do
          expect {
            patch mark_all_as_read_publishers_notifications_path
          }.to change { publisher.notifications.unread.count }.from(3).to(0)
        end
        expect(response).to redirect_to(publishers_notifications_path)
      end

      context "when notifications span more than one page" do
        before do
          # Create 28 notifications because we show 30 per page and want them to be across 2 pages to test this (and we already have 3)
          28.times do
            Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(publisher)
          end
        end

        it "only marks notifications on the current page as read" do
          # Page 1 has 30 notifications (NOTIFICATIONS_PER_PAGE), so marking all on page 1 should leave 1 unread (on page 2)
          patch mark_all_as_read_publishers_notifications_path
          expect(publisher.notifications.unread.count).to eq(1)
        end

        it "only marks notifications on page 2 as read when on page 2" do
          # Page 2 has 1 notification, so marking all on page 2 should leave 30 unread (on page 1)
          patch mark_all_as_read_publishers_notifications_path(page: 2)
          expect(publisher.notifications.unread.count).to eq(30)
        end
      end
    end

    context "when signed out" do
      it "redirects to the publisher sign in page" do
        get publishers_notifications_path
        expect(response).to redirect_to(new_publisher_session_path(redirected: true))
      end
    end
  end
end
