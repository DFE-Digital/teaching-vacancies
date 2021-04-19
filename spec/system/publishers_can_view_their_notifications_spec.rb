require "rails_helper"

RSpec.describe "Publishers can view their notifications" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :published, organisation_vacancies_attributes: [{ organisation: organisation }], publisher: publisher) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before do
    stub_const("Publishers::NotificationsController::DEFAULT_NOTIFICATIONS_PER_PAGE", 1)
    Publishers::JobApplicationReceivedNotification.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
    Publishers::JobApplicationReceivedNotification.with(vacancy: vacancy, job_application: job_application).deliver(vacancy.publisher)
    login_publisher(publisher: publisher, organisation: organisation)
    visit root_path
  end

  it "clicks notifications link, renders the notifications, paginates, and marks as read" do
    click_on I18n.t("nav.notifications_index_link")

    expect(page).to have_css("div", class: "notification-component", count: 1) do |notification|
      expect(notification).to have_css("div", class: "notification-component__tag", text: "new", count: 1)
    end

    click_on "Next"

    expect(page).to have_css("div", class: "notification-component", count: 1) do |notification|
      expect(notification).to have_css("div", class: "notification-component__tag", text: "new", count: 1)
    end

    click_on "Previous"

    expect(page).to have_css("div", class: "notification-component", count: 1) do |notification|
      expect(notification).not_to have_css("div", class: "notification-component__tag", text: "new", count: 1)
    end
  end
end
