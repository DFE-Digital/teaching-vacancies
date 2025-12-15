require "rails_helper"

RSpec.describe "Publisher notifications" do
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, vacancy: vacancy) }

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

      it "marks notifications as read" do
        notification = publisher.notifications.first
        freeze_time do
          expect { get publishers_notifications_path }.to change { notification.reload.read_at }.from(nil).to(Time.current)
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
