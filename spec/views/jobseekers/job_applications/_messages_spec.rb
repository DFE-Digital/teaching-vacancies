require "rails_helper"

RSpec.describe "jobseekers/job_applications/_messages.html.slim" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :submitted, jobseeker: jobseeker) }
  let(:messages) { [] }

  let(:message_form) do 
    instance_double("Publishers::JobApplication::MessagesForm",
      model_name: instance_double("ActiveModel::Name", param_key: "publishers_job_application_messages_form"),
      to_key: nil,
      persisted?: false,
      errors: instance_double("ActiveModel::Errors", empty?: true, any?: false),
      content: ""
    )
  end

  before do
    assign(:job_application, job_application)
    assign(:show_form, "false")
    assign(:message_form, message_form)
    allow(view).to receive_messages(current_user: jobseeker, params: ActionController::Parameters.new({}), url_for: "/test-url")
  end

  context "when messaging is allowed" do
    before do
      allow(view).to receive(:can_jobseeker_send_message?).with(job_application).and_return(true)
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
      allow(view).to receive(:can_jobseeker_send_message?).with(job_application).and_return(false)
    end

    it "shows disabled messaging message and no 'Send message to hiring staff' button with no messages" do
      render partial: "jobseekers/job_applications/messages", locals: { messages: messages }

      expect(rendered).to have_text("Messaging is not available for this application")
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

        expect(rendered).to have_text("Messaging is not available for this application")
        expect(rendered).to have_css("#messages-list")
        expect(rendered).to have_text("Previous message content")
        expect(rendered).to have_no_text(I18n.t("jobseekers.job_applications.messages.no_messages_yet"))
      end
    end
  end
end
