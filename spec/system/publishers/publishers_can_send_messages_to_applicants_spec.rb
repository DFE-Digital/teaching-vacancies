require "rails_helper"

RSpec.describe "Publishers can send messages to job applicants" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :submitted, vacancy: vacancy) }

  context "when logged in as a publisher" do
    before do
      login_publisher(publisher: publisher, organisation: organisation)
    end

    after { logout }

    context "with messages from 2 different publishers" do
      let(:jobseeker) { job_application.jobseeker }
      let(:another_publisher) { create(:publisher) }
      let!(:conversation) { create(:conversation, job_application: job_application) }

      before do
        create(:publisher_message, conversation: conversation, sender: publisher)
        create(:publisher_message, conversation: conversation, sender: another_publisher)
        create(:jobseeker_message, conversation: conversation, sender: jobseeker)
        visit messages_organisation_job_job_application_path(vacancy.id, job_application.id)
      end

      # This should be a view test, but it resisted all efforts to make it so.
      # https://clayshentrup.medium.com/better-rails-partial-rendering-1d30cf7f53c5 suggests a way forward.
      # but we want the namespaces in this instance
      # https://github.com/rspec/rspec-rails/issues/396 suggests setting the partial lookup path
      # view.lookup_context.prefixes << 'intranet/application' << 'application' but it didn't seem to work
      it "shows the correct headers for each message", :js do
        expect(all(".govuk-summary-card__title-wrapper").map { |x| x[:class].split.last }).to eq(["message-header--recipient", "message-header--sender", "message-header--sender"])
      end
    end

    context "when viewing a job application messages tab" do
      it "allows publisher to send a message to the job applicant", :js do
        visit messages_organisation_job_job_application_path(vacancy.id, job_application.id)

        expect(page).to have_link("Print this page")
        expect(page).to have_link("Send message to candidate")

        click_link "Send message to candidate"

        expect(page).to have_no_link("Print this page")
        expect(page).to have_no_link("Send message to candidate")

        click_button "Send message"

        expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
        within(".govuk-error-summary__body") do
          expect(page).to have_link("Please enter your message")
        end

        message_content = "Hi John, I hope you're well. Just a quick reminder to complete your declaration form."
        fill_in_trix_editor "publishers_job_application_messages_form_content", with: message_content

        click_button "Send message"

        expect(page).to have_text("Message sent successfully")
        expect(page).to have_text(message_content)
        expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
        expect(page).to have_text("Regarding application: #{vacancy.job_title}")
      end
    end

    context "when messages already exist", :js do
      let!(:conversation) { create(:conversation, job_application: job_application) }
      let!(:message) { create(:publisher_message, conversation: conversation, sender: publisher, content: "Previous message content") }

      it "displays existing messages and allows sending additional messages" do
        visit messages_organisation_job_job_application_path(vacancy.id, job_application.id)

        expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
        expect(page).to have_text("Previous message content")
        expect(page).to have_text("Regarding application: #{vacancy.job_title}")
        expect(page).to have_text(message.created_at.strftime("%d %B %Y at %I:%M %p"))
        expect(page).to have_no_text("No messages have been sent yet.")

        click_link "Send message to candidate"

        new_message_content = "This is a follow-up message."
        fill_in_trix_editor "publishers_job_application_messages_form_content", with: new_message_content

        click_button "Send message"

        expect(conversation.reload.messages.count).to eq(2)
        message_cards = all(".govuk-summary-card")
        expect(message_cards.first).to have_text(new_message_content)
        expect(message_cards.last).to have_text("Previous message content")
      end

      it "shows validation errors with existing messages when sending blank message" do
        visit messages_organisation_job_job_application_path(vacancy.id, job_application.id)

        expect(page).to have_text("Previous message content")

        click_link "Send message to candidate"
        click_button "Send message"

        expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
        expect(page).to have_text("Previous message content")
        expect(conversation.reload.messages.count).to eq(1)
      end
    end
  end

  context "when jobseeker replies to messages" do
    let(:jobseeker) { job_application.jobseeker }
    let!(:conversation) { create(:conversation, job_application: job_application) }
    let!(:publisher_message) { create(:publisher_message, conversation: conversation, sender: publisher, content: "Hello from publisher") }
    let!(:job_application_without_messages) { create(:job_application, :submitted, vacancy: vacancy, jobseeker: jobseeker) }

    before { login_as(jobseeker, scope: :jobseeker) }

    after { logout }

    it "displays existing publisher messages to jobseeker and allows jobseeker to reply to publisher messages", :js do
      visit jobseekers_job_application_path(job_application, tab: "messages")

      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
      expect(page).to have_text("Hello from publisher")
      expect(page).to have_text("Regarding application: #{vacancy.job_title}")
      expect(page).to have_text(publisher_message.created_at.strftime("%d %B %Y at %I:%M %p"))

      expect(page).to have_link("Send message to hiring staff")
      expect(page).to have_no_link("Print this page")
      expect(page).to have_no_text("If a candidate responds with their pre-interview documentation")

      click_link "Send message to hiring staff"

      expect(page).to have_css(".trix-content")
      expect(page).to have_button("Send message")
      expect(page).to have_link("Cancel")
      expect(page).to have_text("How will this message be sent?")

      # cannot send empty message
      click_button "Send message"

      expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
      within(".govuk-error-summary__body") do
        expect(page).to have_link("Please enter your message")
      end

      jobseeker_reply = "Thank you for your message. I look forward to hearing from you."
      fill_in_trix_editor "publishers_job_application_messages_form_content", with: jobseeker_reply

      click_button "Send message"

      expect(page).to have_text("Message sent successfully")
      expect(page).to have_text(job_application.name.to_s)
      expect(conversation.reload.messages.count).to eq(2)
      message_cards = all(".govuk-summary-card")
      expect(message_cards.first).to have_text(jobseeker_reply)
      expect(message_cards.last).to have_text("Hello from publisher")
    end

    it "shows jobseeker reply in publisher interface" do
      create(:jobseeker_message, conversation: conversation, sender: jobseeker, content: "Jobseeker reply content")

      login_publisher(publisher: publisher, organisation: organisation)

      visit messages_organisation_job_job_application_path(vacancy.id, job_application.id)

      expect(page).to have_text("Hello from publisher")
      expect(page).to have_text("Jobseeker reply content")
      expect(page).to have_text(job_application.name.to_s)
      expect(page).to have_text("#{publisher.given_name} #{publisher.family_name}")
    end

    it "shows no messages interface when no conversation exists" do
      visit jobseekers_job_application_path(job_application_without_messages, tab: "messages")

      expect(page).to have_text("No messages yet. Hiring staff can start a conversation with you here.")
      expect(page).to have_no_link("Send message to hiring staff")
      expect(page).to have_no_css(".trix-content")
    end
  end
end
