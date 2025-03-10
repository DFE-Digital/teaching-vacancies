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

  context "when paginating" do
    before do
      stub_const("Publishers::NotificationsController::NOTIFICATIONS_PER_PAGE", 1)
      Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
      Publishers::JobApplicationReceivedNotifier.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
      visit root_path
    end

    it "clicks notifications link, renders the notifications, paginates, and marks as read" do
      click_on strip_tags(I18n.t("nav.notifications_html", count: 2))

      within first(".notification") do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 1)
      end

      click_on "Next"

      within first(".notification") do
        expect(page).to have_css("div", class: "notification__tag", text: "new", count: 1)
      end

      click_on "Previous"

      within first(".notification") do
        expect(page).not_to have_css("div", class: "notification__tag", text: "new", count: 1)
      end
    end
  end
end
