require "rails_helper"

RSpec.describe "Publishers can view candidate messages" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }

  let(:health_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
  let(:music_vacancy) { create(:vacancy, :live, organisations: [organisation]) }

  let(:health_job_application) { create(:job_application, :status_interviewing, vacancy: health_vacancy, jobseeker: jobseeker) }
  let(:music_job_application) { create(:job_application, :status_interviewing, vacancy: music_vacancy, jobseeker: jobseeker) }

  before { login_publisher(publisher: publisher, organisation: organisation) }
  after { logout }

  context "when conversations exist" do
    let(:health_conversation) { create(:conversation, job_application: health_job_application) }
    let(:music_conversation) { create(:conversation, job_application: music_job_application) }

    before do
      create(:jobseeker_message, conversation: health_conversation, sender: jobseeker, read: true, created_at: 1.day.ago)
      create(:jobseeker_message, conversation: music_conversation, sender: jobseeker, read: false, created_at: 2.days.ago)
    end

    context "when on the inbox tab" do
      before do
        visit publishers_candidate_messages_path
        # wait for page load
        find("nav.tabs-component")
        find("footer")
      end

      it "passes accessibility checks", :a11y do
        expect(page).to be_axe_clean
      end

      it "shows inbox tab with correct count, proper ordering, and allows publishers to archive messages" do
        expect(page).to have_content("Inbox (1)")

        within("tbody") do
          expect(page).to have_content(health_job_application.name)
          expect(page).to have_content(music_job_application.name)
          expect(page).to have_no_content("No messages yet")
        end

        expect(candidate_names).to eq([music_job_application.name, health_job_application.name])
        read_job_applications_messages_and_return_to_candidate_messages_page(music_job_application)

        expect(page).to have_content("Inbox (0)")
        expect(candidate_names).to eq([health_job_application.name, music_job_application.name])

        check("Select #{health_job_application.name}")
        click_button "Archive"

        expect(page).to have_content("You have moved messages to archived")
        expect(page).to have_content("Inbox (0)")
        expect(health_conversation.reload).to be_archived
        expect(music_conversation.reload).not_to be_archived
      end

      context "with multiple conversations selected" do
        it "archives all selected conversations" do
          check("Select #{health_job_application.name}")
          check("Select #{music_job_application.name}")
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

      context "with a third vacancy" do
        let(:third_vacancy) { create(:vacancy, :live, organisations: [organisation]) }
        let(:third_job_application) { create(:job_application, vacancy: third_vacancy, jobseeker: jobseeker, status: "interviewing") }

        before do
          travel_to 3.days.ago do
            third_conversation = create(:conversation, job_application: third_job_application, archived: false)
            create(:jobseeker_message, conversation: third_conversation, sender: jobseeker, read: true)
          end

          visit publishers_candidate_messages_path
        end

        it "allows sorting conversations by different criteria", :js do
          expect(page).to have_select("sort_by", selected: "Unread on top")

          # music_conversation should be first because it has unread messages then ordered by last_message_at desc
          expect(candidate_names).to eq([music_job_application.name, health_job_application.name, third_job_application.name])

          select "Newest on top", from: "sort_by"
          expect(page).to have_select("sort_by", selected: "Newest on top")

          expect(candidate_names).to eq([health_job_application.name, music_job_application.name, third_job_application.name])

          select "Oldest on top", from: "sort_by"
          expect(page).to have_select("sort_by", selected: "Oldest on top")

          expect(candidate_names).to eq([third_job_application.name, music_job_application.name, health_job_application.name])
        end
      end
    end

    describe "unarchiving conversations" do
      before do
        health_conversation.update!(archived: true)
        music_conversation.update!(archived: true)
        visit publishers_candidate_messages_path(tab: "archive")
      end

      it "passes accessibility checks", :a11y do
        expect(page).to be_axe_clean
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

          # health_conversation is marked as read so won't show up in the inbox count, so inbox total is still 1 based on the single unread message.
          expect(page).to have_content("Inbox (1)")
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

  def read_job_applications_messages_and_return_to_candidate_messages_page(job_application)
    click_link "#{job_application.first_name} #{job_application.last_name}"
    visit publishers_candidate_messages_path
  end

  def candidate_names
    page.all("table tbody tr > td")
        .to_a
        .in_groups_of(4)
        .map { |row| row[1].text }
  end
end
