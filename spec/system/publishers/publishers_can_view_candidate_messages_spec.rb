require "rails_helper"

RSpec.describe "Publishers can view candidate messages", :js do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }

  let(:health_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:music_vacancy) { create(:vacancy, :live, organisations: [organisation]) }

  let(:health_job_application) { create(:job_application, vacancy: health_vacancy, jobseeker: jobseeker, status: "interviewing") }
  let(:music_job_application) { create(:job_application, vacancy: music_vacancy, jobseeker: jobseeker, status: "interviewing") }

  before { login_publisher(publisher: publisher, organisation: organisation) }
  after { logout }

  context "when conversations exist" do
    let!(:health_conversation) { create(:conversation, job_application: health_job_application, archived: false) }
    let!(:music_conversation) { create(:conversation, job_application: music_job_application, archived: false) }

    before do
      travel_to 2.days.ago do
        create(:jobseeker_message, conversation: health_conversation, sender: jobseeker)
      end
      travel_to 1.day.ago do
        create(:jobseeker_message, conversation: music_conversation, sender: jobseeker)
      end
    end

    describe "viewing candidate messages" do
      context "when on the inbox tab" do
        before do
          visit publishers_candidate_messages_path
        end

        it "shows inbox tab with correct count, proper ordering, and allows publishers to archive messages" do
          expect(page).to have_content("Inbox (2)")
          expect(page).to have_content("Archive")

          within("tbody") do
            expect(page).to have_content(health_job_application.name)
            expect(page).to have_content(music_job_application.name)
            expect(page).to have_no_content("No messages yet")
          end

          conversation_rows = page.all("table tbody tr")
          expect(conversation_rows.count).to eq(2)

          within(conversation_rows[0]) do
            expect(page).to have_content(music_job_application.name)
          end

          within(conversation_rows[1]) do
            expect(page).to have_content(health_job_application.name)
          end

          read_job_applications_messages_and_return_to_candidate_messages_page(music_job_application)

          expect(page).to have_content("Inbox (1)")

          conversation_rows = page.all("table tbody tr")
          expect(conversation_rows.count).to eq(2)

          within(conversation_rows[0]) do
            expect(page).to have_content(health_job_application.name)
          end

          within(conversation_rows[1]) do
            expect(page).to have_content(music_job_application.name)
          end

          check("Select #{health_job_application.name}", match: :first)
          click_button "Archive"

          expect(page).to have_content("You have moved messages to archived")
          expect(page).to have_content("Inbox (0)")
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
    let(:job_application) { create(:job_application, :submitted, vacancy: vacancy, status: "interviewing") }
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

  def read_job_applications_messages_and_return_to_candidate_messages_page(job_application)
    click_link "#{job_application.first_name} #{job_application.last_name}"
    visit publishers_candidate_messages_path
  end

  describe "searching candidate messages" do
    let(:science_vacancy) { create(:vacancy, :live, job_title: "Science Teacher", organisations: [organisation]) }
    let(:math_vacancy) { create(:vacancy, :live, job_title: "Mathematics Teacher", organisations: [organisation]) }

    let(:science_application) { create(:job_application, vacancy: science_vacancy, jobseeker: jobseeker, status: "interviewing") }
    let(:math_application) { create(:job_application, vacancy: math_vacancy, jobseeker: jobseeker, status: "interviewing") }

    let!(:science_conversation) { create(:conversation, job_application: science_application) }
    let!(:math_conversation) { create(:conversation, job_application: math_application) }

    before do
      create(:jobseeker_message, conversation: science_conversation, sender: jobseeker, content: "Looking forward to the interview")
      create(:jobseeker_message, conversation: math_conversation, sender: jobseeker, content: "Thank you for considering my application")
    end

    context "when searching by job title" do
      it "filters conversations by job title and allows clearing search" do
        visit publishers_candidate_messages_path

        expect(page).to have_content("2 messages")

        within("table tbody") do
          expect(page).to have_content("Science Teacher")
          expect(page).to have_content("Mathematics Teacher")
        end

        fill_in "keyword", with: "Science"
        click_button "Search"

        expect(page).to have_content("1 result found for 'Science'")

        within("table tbody") do
          expect(page).to have_content("Science Teacher")
          expect(page).to have_no_content("Mathematics Teacher")
        end

        click_link "Clear search"

        expect(page).to have_content("2 messages")

        within("table tbody") do
          expect(page).to have_content("Science Teacher")
          expect(page).to have_content("Mathematics Teacher")
        end
      end
    end

    context "when searching by message content" do
      it "filters conversations by message content" do
        visit publishers_candidate_messages_path

        fill_in "keyword", with: "interview"
        click_button "Search"

        expect(page).to have_content("1 result found for 'interview'")

        within("table tbody") do
          expect(page).to have_content("Science Teacher")
          expect(page).to have_no_content("Mathematics Teacher")
        end
      end
    end

    context "when searching with no results" do
      it "shows no results message" do
        visit publishers_candidate_messages_path

        fill_in "keyword", with: "nonexistent"
        click_button "Search"

        expect(page).to have_content("0 results found for 'nonexistent'")
        expect(page).to have_content("No messages yet.")
      end
    end

    context "when searching within archive tab" do
      let(:archived_science_vacancy) { create(:vacancy, :live, job_title: "Physics and Science", organisations: [organisation]) }
      let(:archived_science_application) { create(:job_application, vacancy: archived_science_vacancy, jobseeker: jobseeker, status: "interviewing") }
      let!(:archived_science_conversation) { create(:conversation, job_application: archived_science_application, archived: true) }

      before do
        create(:jobseeker_message, conversation: archived_science_conversation, sender: jobseeker, content: "Archived message")
      end

      it "searches only within archived conversations, not inbox conversations" do
        visit publishers_candidate_messages_path(tab: "archive")

        fill_in "keyword", with: "Science"
        click_button "Search"

        expect(page).to have_content("1 result found for 'Science'")

        within("table tbody") do
          expect(page).to have_content("Physics and Science") # Archived conversation
          expect(page).to have_no_content("Science Teacher") # Inbox conversation
          expect(page).to have_no_content("Mathematics Teacher")
        end
      end
    end
  end
end
