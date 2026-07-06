require "rails_helper"

RSpec.describe "jobseekers/job_applications/_messages.html.slim" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :submitted, jobseeker: jobseeker) }
  let(:messages) { [] }

  let(:message) do
    build_stubbed(:jobseeker_message, content: "")
  end

  before do
    assign(:job_application, job_application)
    assign(:show_form, "false")
    assign(:message, message)
    allow(view).to receive_messages(current_user: jobseeker, params: ActionController::Parameters.new({}), url_for: "/test-url")
  end

  context "when messaging is allowed" do
    before do
      assign(:show_form, "true")
      allow(job_application).to receive(:can_jobseeker_send_message?).and_return(true)
    end

    it "shows 'Send message' button and no disabled message" do
      render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

      expect(rendered).to have_button("Send message")
      expect(rendered).to have_no_text("Messaging is not available for this application")
    end

    it "shows no messages text when no messages exist" do
      render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

      expect(rendered).to have_text(I18n.t("jobseekers.job_applications.messages.no_messages_yet"))
    end

    context "with existing messages" do
      let(:conversation) { create(:conversation, job_application: job_application) }
      let(:messages) { [create(:publisher_message, conversation: conversation)] }

      before do
        allow(view).to receive(:render).and_call_original
        allow(view).to receive(:render).with(partial: messages, locals: { current_user: jobseeker }).and_return("Message content")
      end

      it "shows messages list and no 'no messages' text" do
        render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

        expect(rendered).to have_css("#messages-list")
        expect(rendered).to have_text("Message content")
        expect(rendered).to have_no_text(I18n.t("jobseekers.job_applications.messages.no_messages_yet"))
      end
    end
  end

  context "when messaging is not allowed" do
    before do
      allow(job_application).to receive(:can_jobseeker_send_message?).and_return(false)
    end

    context "when application is withdrawn" do
      before do
        allow(job_application).to receive(:withdrawn?).and_return(true)
      end

      it "shows withdrawn warning" do
        render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

        expect(rendered).to have_css(".govuk-warning-text")
        expect(rendered).to have_text(I18n.t("jobseekers.job_applications.messages.messaging_not_available.withdrawn"))
      end
    end

    context "when jobseeker can reply but not initiate" do
      before do
        allow(job_application).to receive_messages(withdrawn?: false, can_jobseeker_reply_to_message?: true)
      end

      it "shows cannot initiate warning" do
        render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

        expect(rendered).to have_css(".govuk-warning-text")
        expect(rendered).to have_text(I18n.t("jobseekers.job_applications.messages.messaging_not_available.cannot_initiate"))
      end
    end

    context "when jobseeker cannot message at all" do
      before do
        allow(job_application).to receive_messages(withdrawn?: false, can_jobseeker_reply_to_message?: false)
      end

      it "shows cannot message at all warning" do
        render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

        expect(rendered).to have_css(".govuk-warning-text")
        expect(rendered).to have_text(I18n.t("jobseekers.job_applications.messages.messaging_not_available.cannot_message_at_all"))
      end
    end

    it "shows disabled messaging message and no 'Send message to hiring staff' button with no messages" do
      render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

      expect(rendered).to have_text(I18n.t("jobseekers.job_applications.messages.no_messages_yet"))
    end

    context "with existing messages" do
      let(:conversation) { create(:conversation, job_application: job_application) }
      let(:messages) { [create(:publisher_message, conversation: conversation)] }

      before do
        allow(view).to receive(:render).and_call_original
        allow(view).to receive(:render).with(partial: messages, locals: { current_user: jobseeker }).and_return("Previous message content")
      end

      it "shows existing messages, disabled messaging message and no 'Send message to hiring staff' button" do
        render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

        expect(rendered).to have_text("You cannot contact the school at this stage in your application")
        expect(rendered).to have_css("#messages-list")
        expect(rendered).to have_text("Previous message content")
        expect(rendered).to have_no_text(I18n.t("jobseekers.job_applications.messages.no_messages_yet"))
      end
    end
  end
end
