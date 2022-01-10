require "rails_helper"

RSpec.describe NotificationComponent, type: :component do
  let(:notification) { build_stubbed(:notification, :job_application_received).to_notification }
  let(:kwargs) { { notification: } }

  before do
    allow(notification).to receive(:message).and_return("Test message")
    allow(notification).to receive(:timestamp).and_return("Test timestamp")
  end

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the notification message" do
    expect(page).to have_css("div", class: "notification-component") do |notification|
      expect(notification).to have_css("div", class: "notification-component__message", text: "Test message")
    end
  end

  it "renders the notification timestamp" do
    expect(page).to have_css("div", class: "notification-component") do |notification|
      expect(notification).to have_css("div", class: "notification-component__timestamp", text: "Test timestamp")
    end
  end

  context "when the notification is unread" do
    it "renders the unread tag" do
      expect(page).to have_css("div", class: "notification-component") do |notification|
        expect(notification).to have_css("div", class: "notification-component__tag")
      end
    end
  end

  context "when the notification is read" do
    let(:notification) { build_stubbed(:notification, :job_application_received, read_at: Time.current).to_notification }

    it "does not render the unread tag" do
      expect(page).to have_css("div", class: "notification-component") do |notification|
        expect(notification).not_to have_css("div", class: "notification-component__tag")
      end
    end
  end
end
