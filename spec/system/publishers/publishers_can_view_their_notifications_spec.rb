require "rails_helper"

RSpec.describe "Publishers can view their notifications" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :published, organisations: [organisation], publisher: publisher) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "when the notification was created outside the data access period" do
    before do
      Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
      publisher.notifications.first.update(created_at: Time.now - 2.years)
      visit publishers_notifications_path
    end

    it "does not display the notification" do
      expect(page).not_to have_css("div", class: "notification")
    end
  end

  context "when paginating", :inline_jobs do
    before do
      stub_const("Publishers::NotificationsController::NOTIFICATIONS_PER_PAGE", 2)

      [3, 2, 1].each do |delay|
        travel_to delay.days.ago do
          v = create(:vacancy, :published, organisations: [organisation], publisher: publisher, job_title: "#{delay} ago")
          application = create(:job_application, :status_submitted, vacancy: v, create_details: true)

          ref_req = create(:reference_request, referee: application.referees.first)
          ref = create(:job_reference, referee: application.referees.first)

          Publishers::ReferenceReceivedNotifier.with(record: ref, reference_request: ref_req)
                                               .deliver(publisher)
          disc_ref = create(:self_disclosure_request, job_application: application)
          self_disc = create(:self_disclosure, self_disclosure_request: disc_ref)
          Publishers::SelfDeclarationReceivedNotifier.with(record: self_disc,
                                                           job_application: application)
                                                     .deliver(publisher)
        end
      end

      visit root_path
      click_on strip_tags(I18n.t("nav.notifications_html", count: 6))
    end

    it "clicks notifications link, renders the notifications, paginates, and marks as read", :js do
      within "#notifications-results" do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 2)
      end

      click_on "Next"
      # wait for page load
      find(".govuk-pagination__prev", wait: 10)

      within "#notifications-results" do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 2)
      end

      click_on "3"

      within "#notifications-results" do
        expect(page).not_to have_css("div", class: "notification__tag", text: "new", count: 2)
      end
    end
  end
end
