require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/messages.html.slim" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :submitted, vacancy: vacancy, status: "interviewing") }
  let(:messages) { [] }

  let(:message) do
    build_stubbed(:publisher_message, content: "")
  end

  before do
    assign(:show_form, "true")
    assign(:message, message)
    assign(:vacancy, vacancy)
    assign(:job_application, job_application)
    assign(:messages, messages)
    assign(:back_link, publishers_candidate_messages_path)
    # supplying dummy URL so that it doesn't crash during rendering. No need for a real URL as we aren't actually clicking the button.
    allow(view).to receive_messages(current_user: publisher, params: ActionController::Parameters.new({ show_form: "false" }), url_for: "/test-url")
  end

  context "when messaging is allowed" do
    before do
      allow(job_application).to receive(:can_publisher_send_message?).and_return(true)
    end

    it "shows send message button and hides disabled messages button button" do
      render template: "publishers/vacancies/job_applications/messages"

      expect(rendered).to have_button("Send message")
      expect(rendered).to have_no_text("Messaging is not available for this application")
    end

    context "when showing form and application is unsuccessful" do
      before do
        assign(:show_form, "true")
        allow(job_application).to receive(:unsuccessful?).and_return(true)
      end

      it "shows messaging after rejection warning" do
        render template: "publishers/vacancies/job_applications/messages"

        expect(rendered).to have_css(".govuk-warning-text")
        expect(rendered).to have_text(I18n.t("publishers.vacancies.job_applications.messages.messaging_after_rejection"))
      end
    end

    it "shows no messages text when no messages exist" do
      render template: "publishers/vacancies/job_applications/messages"

      expect(rendered).to have_text("No messages yet")
    end

    context "with existing messages" do
      let(:conversation) { create(:conversation, job_application: job_application) }
      let(:messages) { [create(:jobseeker_message, conversation: conversation)] }

      before do
        assign(:messages, messages)
        allow(view).to receive(:render).and_call_original
        allow(view).to receive(:render).with(partial: messages, locals: { current_user: publisher, job_application: job_application }).and_return("Message content")
      end

      it "shows messages list and no 'no messages' text" do
        render template: "publishers/vacancies/job_applications/messages"

        expect(rendered).to have_css("#messages-list")
        expect(rendered).to have_text("Message content")
        expect(rendered).to have_no_text("No messages yet")
      end
    end
  end

  context "when messaging is not allowed" do
    let(:conversation) { create(:conversation, job_application: job_application) }
    let(:messages) { [create(:jobseeker_message, conversation: conversation)] }

    before do
      assign(:messages, messages)
      allow(job_application).to receive(:can_publisher_send_message?).and_return(false)
      allow(view).to receive(:render).and_call_original
      allow(view).to receive(:render).with(partial: messages, locals: { current_user: publisher, job_application: job_application }).and_return("Previous message content")
    end

    it "shows existing messages, disabled messaging message and hides buttons" do
      render template: "publishers/vacancies/job_applications/messages"

      expect(rendered).to have_no_link("Send message to candidate")
      expect(rendered).to have_text("Previous message content")
    end
  end
end
