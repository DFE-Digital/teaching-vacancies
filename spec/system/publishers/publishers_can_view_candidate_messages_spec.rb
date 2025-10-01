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

  def read_job_applications_messages_and_return_to_candidate_messages_page(job_application)
    click_link "#{job_application.first_name} #{job_application.last_name}"
    visit publishers_candidate_messages_path
  end

  context "when publisher is a MAT and is publishing vacancies for schools" do
    let(:trust) { create(:trust) }
    let(:primary_school) { create(:school, school_groups: [trust]) }
    let(:secondary_school) { create(:school, school_groups: [trust]) }
    let(:trust_publisher) { create(:publisher, organisations: [trust]) }
    let(:school_publisher) { create(:publisher, organisations: [secondary_school]) }

    let(:vacancy_published_by_trust) { create(:vacancy, :live, organisations: [primary_school], publisher: trust_publisher) }
    let(:vacancy_published_by_school) { create(:vacancy, :live, organisations: [secondary_school], publisher: school_publisher) }

    let(:trust_published_vacancy) { create(:job_application, :status_submitted, vacancy: vacancy_published_by_trust, jobseeker: jobseeker) }
    let(:school_published_vacancy) { create(:job_application, :status_submitted, vacancy: vacancy_published_by_school, jobseeker: jobseeker) }

    let!(:trust_published_conversation) { create(:conversation, job_application: trust_published_vacancy, archived: false) }
    let!(:school_published_conversation) { create(:conversation, job_application: school_published_vacancy, archived: false) }

    before do
      create(:jobseeker_message, conversation: trust_published_conversation, sender: jobseeker)
      create(:jobseeker_message, conversation: school_published_conversation, sender: jobseeker)
      login_publisher(publisher: trust_publisher, organisation: trust)
    end

    after { logout }

    it "shows messages from all applicants for schools jobs" do
      visit publishers_candidate_messages_path

      expect(page).to have_content("Inbox (2)")

      within("tbody") do
        expect(page).to have_content(trust_published_vacancy.name)
        expect(page).to have_content(school_published_vacancy.name)
        expect(page).to have_no_content("No messages yet")
      end

      conversation_rows = page.all("table tbody tr")
      expect(conversation_rows.count).to eq(2)
    end

    it "allows archiving messages all applicants for schools jobs" do
      visit publishers_candidate_messages_path

      check("Select #{trust_published_vacancy.name}", match: :first)
      click_button "Archive"

      expect(page).to have_content("You have moved messages to archived")
      expect(page).to have_content("Inbox (1)")
      expect(trust_published_conversation.reload).to be_archived
      expect(school_published_conversation.reload).not_to be_archived
    end

    context "when the school publisher logs in" do
      before do
        logout
        login_publisher(publisher: school_publisher, organisation: secondary_school)
      end

      it "can see messages from their own school" do
        visit publishers_candidate_messages_path

        expect(page).to have_content("Inbox (1)")

        within("tbody") do
          expect(page).to have_content(school_published_vacancy.name)
          expect(page).to have_no_content(trust_published_vacancy.name)
        end

        conversation_rows = page.all("table tbody tr")
        expect(conversation_rows.count).to eq(1)
      end
    end
  end
end
