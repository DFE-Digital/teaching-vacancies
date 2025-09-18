require "rails_helper"

RSpec.describe "Publishers can view candidate messages", :js do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }

  let(:health_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:music_vacancy) { create(:vacancy, :live, organisations: [organisation]) }

  let(:health_job_application) { create(:job_application, :status_submitted, vacancy: health_vacancy, jobseeker: jobseeker) }
  let(:music_job_application) { create(:job_application, :status_submitted, vacancy: music_vacancy, jobseeker: jobseeker) }

  before { login_publisher(publisher: publisher, organisation: organisation) }
  after { logout }

  context "when conversations exist" do
    let!(:health_conversation) { create(:conversation, job_application: health_job_application, archived: false) }
    let!(:music_conversation) { create(:conversation, job_application: music_job_application, archived: false) }

    before do
      create(:jobseeker_message, conversation: health_conversation, sender: jobseeker)
      create(:jobseeker_message, conversation: music_conversation, sender: jobseeker)
    end

    describe "viewing candidate messages" do
      context "when on the inbox tab" do
        before do
          visit publishers_candidate_messages_path
        end

        it "shows inbox tab with correct count and allows publishers to archive messages" do
          expect(page).to have_content("Inbox (2)")
          expect(page).to have_content("Archive")

          within("tbody") do
            expect(page).to have_content(health_job_application.name)
            expect(page).to have_content(music_job_application.name)
            expect(page).to have_no_content("No messages yet")
          end

          check("Select #{health_job_application.name}", match: :first)
          click_button "Archive"

          expect(page).to have_content("You have moved messages to archived")
          expect(page).to have_content("Inbox (1)")
          expect(health_conversation.reload).to be_archived
          expect(music_conversation.reload).not_to be_archived
        end

        context "with multiple conversations selected" do
          it "archives all selected conversations" do
            check("Select #{health_job_application.name}", match: :first)
            check("Select #{music_job_application.name}", match: :first)
            click_button "Archive"

            expect(page).to have_content("You have moved messages to archived")
            expect(page).to have_content("Inbox (0)")
            expect(health_conversation.reload).to be_archived
            expect(music_conversation.reload).to be_archived
          end
        end

        context "with no conversations selected" do
          it "archives no conversations, with no errors" do
            click_button "Archive"

            expect(page).to have_content("You have moved messages to archived")

            expect(health_conversation.reload).not_to be_archived
            expect(music_conversation.reload).not_to be_archived
          end
        end
      end
    end

    describe "unarchiving conversations" do
      before do
        health_conversation.update!(archived: true)
        music_conversation.update!(archived: true)
        visit publishers_candidate_messages_path(tab: "archive")
      end

      context "with single conversation selected" do
        it "unarchives the selected conversation" do
          expect(page).to have_content("Inbox (0)")
          check("Select #{music_job_application.name}", match: :first)
          click_button "Unarchive"

          expect(page).to have_content("You have moved messages to inbox")
          expect(music_conversation.reload).not_to be_archived
          expect(health_conversation.reload).to be_archived

          expect(page).to have_content("Inbox (1)")
        end
      end

      context "with multiple conversations selected" do
        it "unarchives all selected conversations" do
          check("Select #{health_job_application.name}", match: :first)
          check("Select #{music_job_application.name}", match: :first)
          click_button "Unarchive"

          expect(page).to have_content("You have moved messages to inbox")
          expect(health_conversation.reload).not_to be_archived
          expect(music_conversation.reload).not_to be_archived

          expect(page).to have_content("Inbox (2)")
        end
      end

      context "with no conversations selected" do
        it "unarchives no conversations, with no errors" do
          click_button "Unarchive"

          expect(health_conversation.reload).to be_archived
          expect(music_conversation.reload).to be_archived
        end
      end
    end
  end

  context "when no conversations exist" do
    it "tells users no messages exist yet" do
      visit publishers_candidate_messages_path

      expect(page).to have_content("Inbox (0)")
      expect(page).to have_content("No messages yet.")

      visit publishers_candidate_messages_path(tab: "archive")

      expect(page).to have_content("No archived messages yet.")
    end
  end

  describe "reading messages" do
    let(:vacancy) { create(:vacancy, :live, organisations: [organisation]) }
    let(:job_application) { create(:job_application, :submitted, vacancy: vacancy) }
    let(:jobseeker) { job_application.jobseeker }
    let!(:conversation) { create(:conversation, job_application: job_application) }

    it "updates inbox total and marks message as read" do
      create(:jobseeker_message, conversation: conversation, sender: jobseeker, read: false)

      visit publishers_candidate_messages_path
      expect(page).to have_content("Inbox (1)")

      within("table tbody") do
        expect(page).to have_css("tr.conversation--unread")
      end

      visit messages_organisation_job_job_application_path(vacancy.id, job_application.id)

      visit publishers_candidate_messages_path

      expect(page).to have_content("Inbox (0)")

      within("table tbody") do
        expect(page).to have_no_css("tr.conversation--unread")
      end
    end
  end

  describe "message ordering" do
    let(:oldest_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
    let(:older_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
    let(:middle_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
    let(:newer_vacancy) { create(:vacancy, :live, organisations: [organisation]) }

    let(:oldest_job_application) { create(:job_application, :submitted, vacancy: oldest_vacancy) }
    let(:older_job_application) { create(:job_application, :submitted, vacancy: older_vacancy) }
    let(:middle_job_application) { create(:job_application, :submitted, vacancy: middle_vacancy) }
    let(:newer_job_application) { create(:job_application, :submitted, vacancy: newer_vacancy) }

    let!(:older_unread_conversation) { create(:conversation, job_application: older_job_application) }
    let!(:newer_unread_conversation) { create(:conversation, job_application: newer_job_application) }
    let!(:older_read_conversation) { create(:conversation, job_application: oldest_job_application) }
    let!(:newer_read_conversation) { create(:conversation, job_application: middle_job_application) }

    before do
      travel_to 4.days.ago do
        create(:jobseeker_message, conversation: older_read_conversation, sender: oldest_job_application.jobseeker, read: true)
      end

      travel_to 3.days.ago do
        create(:jobseeker_message, conversation: older_unread_conversation, sender: older_job_application.jobseeker, read: false)
      end

      travel_to 2.days.ago do
        create(:jobseeker_message, conversation: newer_unread_conversation, sender: newer_job_application.jobseeker, read: false)
      end

      travel_to 1.day.ago do
        create(:jobseeker_message, conversation: newer_read_conversation, sender: middle_job_application.jobseeker, read: true)
      end
    end

    it "orders conversations with unread messages first (newest first), then read messages (newest first)" do
      visit publishers_candidate_messages_path

      conversation_rows = page.all("table tbody tr")
      expect(conversation_rows.count).to eq(4)

      within(conversation_rows[0]) do
        expect(page).to have_content(newer_unread_conversation.job_application.name)
      end

      within(conversation_rows[1]) do
        expect(page).to have_content(older_unread_conversation.job_application.name)
      end

      within(conversation_rows[2]) do
        expect(page).to have_content(newer_read_conversation.job_application.name)
      end

      within(conversation_rows[3]) do
        expect(page).to have_content(older_read_conversation.job_application.name)
      end
    end
  end
end
