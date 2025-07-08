require "rails_helper"

RSpec.describe "Publishers can view their notifications" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation], publisher: publisher) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "when the notification was created outside the data access period" do
    before do
      travel_to 2.years.ago do
        Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
      end
      # notifications are created with insert_all, which uses the DB timestamp
      # and hence isn't changed by the travel_to block
      publisher.notifications.each { |n| n.update!(created_at: n.event.created_at) }

      visit publishers_notifications_path
    end

    it "does not display the notification" do
      expect(page).not_to have_css("div", class: "notification")
    end
  end

  context "when paginating" do
    before do
      stub_const("Publishers::NotificationsController::NOTIFICATIONS_PER_PAGE", 2)

      1.upto(3) do |delay|
        travel_to delay.days.ago do
          job_application = create(:job_application, :status_submitted, vacancy: vacancy)
          Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
        end
      end
      # notifications are created with insert_all, which uses the DB timestamp
      # and hence isn't changed by the travel_to block
      publisher.notifications.each { |n| n.update!(created_at: n.event.created_at) }

      visit root_path
      click_on strip_tags(I18n.t("nav.notifications_html", count: 3))
    end

    it "clicks notifications link, renders the notifications, paginates, and marks as read" do
      within "#notifications-results" do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 2)
      end

      click_on "Next"
      # wait for page load
      find(".govuk-pagination__prev", wait: 10)

      within "#notifications-results" do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 1)
      end

      click_on "Previous"
      # wait for page load
      find(".govuk-pagination__next")

      within "#notifications-results" do
        expect(page).not_to have_css("div", class: "notification__tag", text: "new", count: 2)
      end
    end
  end
end
