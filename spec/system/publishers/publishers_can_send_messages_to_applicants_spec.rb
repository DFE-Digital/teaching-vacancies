require "rails_helper"

RSpec.describe "Publishers can send messages to job applicants" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :submitted, vacancy: vacancy) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "when viewing a job application messages tab" do
    it "allows publisher to send a message to the job applicant", :js do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      expect(page).to have_link("Print this page")
      expect(page).to have_link("Send message to candidate")

      click_link "Send message to candidate"

      expect(page).to have_no_link("Print this page")
      expect(page).to have_no_link("Send message to candidate")

      click_button "Send message"

      expect(page).to have_text("Message could not be sent")

      click_link "Send message to candidate"

      message_content = "Hi John, I hope you're well. Just a quick reminder to complete your declaration form."
      fill_in_trix_editor "message_content", with: message_content

      click_button "Send message"

      expect(page).to have_text("Message sent successfully")
      expect(page).to have_text(message_content)
      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
      expect(page).to have_text("Regarding application: #{vacancy.job_title}")
    end
  end

  context "when messages already exist", :js do
    let!(:conversation) { create(:conversation, job_application: job_application) }
    let!(:message) { create(:message, conversation: conversation, sender: publisher, content: "Previous message content") }

    it "displays existing messages and allows sending additional messages" do
      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
      expect(page).to have_text("Previous message content")
      expect(page).to have_text("Regarding application: #{vacancy.job_title}")
      expect(page).to have_text(message.created_at.strftime("%d %B %Y at %I:%M %p"))
      expect(page).to have_no_text("No messages have been sent yet.")

      click_link "Send message to candidate"

      new_message_content = "This is a follow-up message."
      fill_in_trix_editor "message_content", with: new_message_content

      click_button "Send message"

      expect(page).to have_text("Previous message content")
      expect(page).to have_text(new_message_content)
      expect(conversation.reload.messages.count).to eq(2)
    end
  end

  context "when jobseeker replies to messages" do
    let(:jobseeker) { job_application.jobseeker }
    let!(:conversation) { create(:conversation, job_application: job_application) }
    let!(:publisher_message) { create(:message, conversation: conversation, sender: publisher, content: "Hello from publisher") }

    before do
      login_as(jobseeker, scope: :jobseeker)
    end

    it "displays existing publisher messages to jobseeker" do
      visit jobseekers_job_application_path(job_application, tab: "messages")

      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
      expect(page).to have_text("Hello from publisher")
      expect(page).to have_text("Regarding application: #{vacancy.job_title}")
      expect(page).to have_text(publisher_message.created_at.strftime("%d %B %Y at %I:%M %p"))
    end

    it "allows jobseeker to reply to publisher messages", :js do
      visit jobseekers_job_application_path(job_application, tab: "messages")

      click_link "Send message to hiring staff"

      jobseeker_reply = "Thank you for your message. I look forward to hearing from you."
      fill_in_trix_editor "message_content", with: jobseeker_reply

      click_button "Send message"

      expect(page).to have_text("Message sent successfully")
      expect(page).to have_text("Hello from publisher")
      expect(page).to have_text(jobseeker_reply)
      expect(page).to have_text(job_application.name.to_s)
      expect(conversation.reload.messages.count).to eq(2)
    end

    it "shows jobseeker reply in publisher interface" do
      create(:message, conversation: conversation, sender: jobseeker, content: "Jobseeker reply content")

      logout
      login_publisher(publisher: publisher, organisation: organisation)

      visit organisation_job_job_application_path(vacancy.id, job_application.id, tab: "messages")

      expect(page).to have_text("Hello from publisher")
      expect(page).to have_text("Jobseeker reply content")
      expect(page).to have_text(job_application.name.to_s)
      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
    end

    it "shows validation errors when jobseeker submits empty message" do
      visit jobseekers_job_application_path(job_application, tab: "messages")

      click_link "Send message to hiring staff"
      click_button "Send message"

      expect(page).to have_text("Message could not be sent")
    end

    it "shows correct interface elements for jobseeker messaging" do
      visit jobseekers_job_application_path(job_application, tab: "messages")

      expect(page).to have_link("Send message to hiring staff")
      expect(page).to have_no_link("Print this page")
      expect(page).to have_no_text("If a candidate responds with their pre-interview documentation")

      click_link "Send message to hiring staff"

      expect(page).to have_css(".trix-content")
      expect(page).to have_button("Send message")
      expect(page).to have_link("Cancel")
      expect(page).to have_text("How will this message be sent?")
      expect(page).to have_text("Hiring staff will receive a copy of this message")
    end

    it "shows no messages interface when no conversation exists" do
      # Create a job application without messages
      job_application_without_messages = create(:job_application, :submitted, vacancy: vacancy)
      logout
      login_as(job_application_without_messages.jobseeker, scope: :jobseeker)

      visit jobseekers_job_application_path(job_application_without_messages, tab: "messages")

      expect(page).to have_text("No messages yet. Hiring staff can start a conversation with you here.")
      expect(page).to have_no_link("Send message to hiring staff")
      expect(page).to have_no_css(".trix-content")
    end
  end
end
