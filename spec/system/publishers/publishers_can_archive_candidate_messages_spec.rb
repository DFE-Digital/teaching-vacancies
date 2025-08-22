require "rails_helper"

RSpec.describe "Publishers can archive and unarchive candidate messages", :js do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }
  let(:jobseeker) { create(:jobseeker) }
  
  let(:vacancy1) { create(:vacancy, :live, publisher_organisation: organisation) }
  let(:vacancy2) { create(:vacancy, :live, publisher_organisation: organisation) }
  
  let(:job_application1) { create(:job_application, :status_submitted, vacancy: vacancy1, jobseeker: jobseeker) }
  let(:job_application2) { create(:job_application, :status_submitted, vacancy: vacancy2, jobseeker: jobseeker) }
  
  let!(:conversation1) { create(:conversation, job_application: job_application1, archived: false) }
  let!(:conversation2) { create(:conversation, job_application: job_application2, archived: false) }
  
  let!(:message1) { create(:message, conversation: conversation1, sender: jobseeker) }
  let!(:message2) { create(:message, conversation: conversation2, sender: jobseeker) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
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
          expect(page).to have_content(job_application1.name)
          expect(page).to have_content(job_application2.name)
          expect(page).not_to have_content("No messages yet")
        end

        check("Select #{job_application1.name}", match: :first)
        click_button "Archive"

        expect(page).to have_content("1 conversation(s) archived successfully")
        expect(page).to have_content("Inbox (1)")
        expect(conversation1.reload).to be_archived
        expect(conversation2.reload).not_to be_archived
      end

      context "with multiple conversations selected" do
        it "archives all selected conversations" do
          check("Select #{job_application1.name}", match: :first)
          check("Select #{job_application2.name}", match: :first)
          click_button "Archive"
  
          expect(page).to have_content("2 conversation(s) archived successfully")
          expect(page).to have_content("Inbox (0)")
          expect(conversation1.reload).to be_archived
          expect(conversation2.reload).to be_archived
        end
      end

      context "with no conversations selected" do
        it "shows an error message" do
          click_button "Archive"
          
          expect(page).to have_content("Please select at least one conversation to archive")
          expect(conversation1.reload).not_to be_archived
          expect(conversation2.reload).not_to be_archived
        end
      end
    end
  end

  describe "unarchiving conversations" do
    before do
      conversation1.update!(archived: true)
      conversation2.update!(archived: true)
      visit publishers_candidate_messages_path(tab: 'archive')
    end

    context "with no conversations selected" do
      it "shows an error message" do
        click_button "Unarchive"
        
        expect(page).to have_content("Please select at least one conversation to unarchive")
        expect(conversation1.reload).to be_archived
        expect(conversation2.reload).to be_archived
      end
    end

    context "with single conversation selected" do
      it "unarchives the selected conversation" do
        expect(page).to have_content("Inbox (0)")
        check("Select #{job_application2.name}", match: :first)
        click_button "Unarchive"

        expect(page).to have_content("1 conversation(s) unarchived successfully")
        expect(conversation2.reload).not_to be_archived
        expect(conversation1.reload).to be_archived

        expect(page).to have_content("Inbox (1)")
      end
    end

    context "with multiple conversations selected" do
      it "unarchives all selected conversations" do
        check("Select #{job_application1.name}", match: :first)
        check("Select #{job_application2.name}", match: :first)
        click_button "Unarchive"

        expect(page).to have_content("2 conversation(s) unarchived successfully")
        expect(conversation1.reload).not_to be_archived
        expect(conversation2.reload).not_to be_archived
      end
    end
  end

  context "when no conversations exist" do
    before do
      Message.destroy_all
      Conversation.destroy_all
    end

    it "tells users no messages exist yet" do
      visit publishers_candidate_messages_path
      
      expect(page).to have_content("Inbox (0)")
      expect(page).to have_content("No messages yet.")

      visit publishers_candidate_messages_path(tab: 'archive')
      
      expect(page).to have_content("No archived messages yet.")
    end
  end
end