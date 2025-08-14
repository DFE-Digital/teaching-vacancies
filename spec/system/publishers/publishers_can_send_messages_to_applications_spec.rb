require "rails_helper"

RSpec.describe "Publishers can send messages to job applicants", type: :system do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :submitted, vacancy: vacancy) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  context "when viewing a job application messages tab" do
    it "shows the correct interface by default" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      expect(page).to have_link("Print this page")
      expect(page).to have_link("Send message to candidate")
      expect(page).to have_text("If a candidate responds with their pre-interview documentation")
      expect(page).not_to have_css("textarea")
      expect(page).to have_text("No messages have been sent yet.")
    end

    it "shows the message form when clicking 'Send message to candidate'" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      click_link "Send message to candidate"

      expect(page).to have_css("h3", text: "Send a new message")
      expect(page).to have_css("textarea")
      expect(page).to have_button("Send message")
      expect(page).to have_link("Cancel")
      expect(page).to have_text("How will this message be sent?")
      expect(page).not_to have_link("Print this page")
      expect(page).not_to have_link("Send message to candidate")
      expect(page).not_to have_text("If a candidate responds with their pre-interview documentation")
    end

    it "allows publisher to send a message to the job applicant" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      click_link "Send message to candidate"

      message_content = "Hi John, I hope you're well. Just a quick reminder to complete your declaration form."
      fill_in "publishers_job_application_messages_form[content]", with: message_content

      click_button "Send message"

      expect(page).to have_text("Message sent successfully")
      expect(page).to have_text(message_content)
      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
      expect(page).to have_text("Regarding application: #{vacancy.job_title}")
    end

    it "shows validation errors for empty messages" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      click_link "Send message to candidate"
      click_button "Send message"

      expect(page).to have_text("Message could not be sent")
    end
  end

  context "when messages already exist" do
    let!(:conversation) { create(:conversation, job_application: job_application) }
    let!(:message) { create(:message, conversation: conversation, sender: publisher, content: "Previous message content") }

    it "displays existing messages" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
      expect(page).to have_text("Previous message content")
      expect(page).to have_text("Regarding application: #{vacancy.job_title}")
      expect(page).to have_text(message.created_at.strftime("%d %B %Y at %I:%M %p"))
      expect(page).not_to have_text("No messages have been sent yet.")
    end

    it "allows sending additional messages" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      click_link "Send message to candidate"

      new_message_content = "This is a follow-up message."
      fill_in "publishers_job_application_messages_form[content]", with: new_message_content

      click_button "Send message"

      expect(page).to have_text("Previous message content")
      expect(page).to have_text(new_message_content)
      expect(conversation.reload.messages.count).to eq(2)
    end
  end
end
