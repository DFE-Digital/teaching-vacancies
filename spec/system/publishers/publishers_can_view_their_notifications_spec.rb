require "rails_helper"

RSpec.describe "Publishers can view their notifications" do
  include ActiveJob::TestHelper

  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation], publisher: publisher) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "when the notification was created outside the data access period", :js do
    before do
      travel_to 2.years.ago do
        Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
      end
      publisher.notifications.each { |n| n.update!(created_at: n.event.created_at) }
      visit publishers_notifications_path
    end

    it "does not display the notification" do
      expect(page).not_to have_css("div", class: "notification")
    end
  end

  context "when paginating", :versioning do
    before do
      stub_const("NotificationsController::NOTIFICATIONS_PER_PAGE", 2)

      [3, 2, 1].each do |delay|
        travel_to delay.days.ago do
          v = create(:vacancy, organisations: [organisation], publisher: publisher, job_title: "#{delay} ago")
          application = create(:job_application, :status_submitted, vacancy: v, create_details: true)

          req = create(:reference_request, referee: application.referees.first)
          job_reference = create(:job_reference, :reference_given, reference_request: req)

          Publishers::ReferenceReceivedNotifier.with(record: job_reference)
                                               .deliver
        end
        travel_to (delay.days + 1.hour).ago do
          v = create(:vacancy, organisations: [organisation], publisher: publisher, job_title: "#{delay} ago")
          application = create(:job_application, :status_submitted, vacancy: v, create_details: true)

          disc_ref = create(:self_disclosure_request, job_application: application)
          self_disc = create(:self_disclosure, self_disclosure_request: disc_ref)
          Publishers::SelfDisclosureReceivedNotifier.with(record: self_disc)
                                                     .deliver
        end
      end

      # notifications are created with insert_all, which uses the DB timestamp
      # and hence isn't changed by the travel_to block
      publisher.notifications.each { |n| n.update!(created_at: n.event.created_at) }

      visit root_path
      click_on strip_tags(I18n.t("nav.notifications_html", count: 6))
    end

    it "clicks notifications link, renders the notifications, paginates, and marks as read" do
      within "#notifications-results" do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 2)
      end

      click_on "Next"
      # wait for page load
      find(".govuk-pagination__prev")

      within "#notifications-results" do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 2)
      end

      click_on "Previous"

      within "#notifications-results" do
        expect(page).not_to have_css("div", class: "notification__tag", text: "new", count: 2)
      end
    end
  end
end
