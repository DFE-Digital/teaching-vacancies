require "rails_helper"

RSpec.describe "Publishers can manage candidate messages" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_publisher(publisher: login_user, organisation: login_organisation)
  end

  after { logout }

  context "when publisher is a MAT and is publishing vacancies for schools" do
    let(:trust) { create(:trust) }
    let(:primary_school) { create(:school, school_groups: [trust]) }
    let(:secondary_school) { create(:school, school_groups: [trust]) }
    let(:trust_publisher) { create(:publisher, organisations: [trust]) }
    let(:school_publisher) { create(:publisher, organisations: [secondary_school]) }

    let(:vacancy_published_by_trust) { create(:vacancy, :live, organisations: [primary_school], publisher: trust_publisher) }
    let(:vacancy_published_by_school) { create(:vacancy, :live, organisations: [secondary_school], publisher: school_publisher) }

    let(:trust_published_vacancy_application) { create(:job_application, :status_interviewing, vacancy: vacancy_published_by_trust, jobseeker: jobseeker) }
    let(:school_published_vacancy_application) { create(:job_application, :status_interviewing, vacancy: vacancy_published_by_school, jobseeker: jobseeker) }

    let!(:trust_published_conversation) { create(:conversation, job_application: trust_published_vacancy_application) }
    let!(:school_published_conversation) { create(:conversation, job_application: school_published_vacancy_application) }

    before do
      create(:jobseeker_message, conversation: trust_published_conversation, sender: jobseeker)
      create(:jobseeker_message, conversation: school_published_conversation, sender: jobseeker)

      visit publishers_candidate_messages_path
      # wait for page load
      find("form[action='/publishers/candidate_messages/toggle_archive']")
    end

    context "with the trust user" do
      let(:login_user) { trust_publisher }
      let(:login_organisation) { trust }

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean
      end

      it "shows messages from applicants for all jobs at their schools, regardless of whether a school or the MAT published it" do
        expect(page).to have_content("Inbox (2)")

        within("tbody") do
          expect(page).to have_content(trust_published_vacancy_application.name)
          expect(page).to have_content(school_published_vacancy_application.name)
          expect(page).to have_no_content("No messages yet")
        end

        conversation_rows = page.all("table tbody tr")
        expect(conversation_rows.count).to eq(2)
      end

      it "allows archiving messages" do
        check("Select #{trust_published_vacancy_application.name}", match: :first)
        click_button "Archive"

        expect(page).to have_content("You have moved messages to archived")
        expect(page).to have_content("Inbox (1)")
        expect(trust_published_conversation.reload).to be_archived
        expect(school_published_conversation.reload).not_to be_archived
      end
    end

    context "when the school publisher logs in" do
      let(:login_user) { school_publisher }
      let(:login_organisation) { secondary_school }

      it "can only see messages on jobs published by their own school" do
        visit publishers_candidate_messages_path

        expect(page).to have_content("Inbox (1)")

        expect(candidate_names).to eq([school_published_vacancy_application.name])
      end
    end
  end

  describe "searching candidate messages" do
    let(:science_vacancy) { create(:vacancy, :live, job_title: "Science Teacher", organisations: [organisation]) }
    let(:math_vacancy) { create(:vacancy, :live, job_title: "Mathematics Teacher", organisations: [organisation]) }

    let(:science_application) { create(:job_application, :status_interviewing, vacancy: science_vacancy, jobseeker: jobseeker) }
    let(:math_application) { create(:job_application, :status_interviewing, vacancy: math_vacancy, jobseeker: jobseeker) }

    let!(:science_conversation) { create(:conversation, job_application: science_application) }
    let!(:math_conversation) { create(:conversation, job_application: math_application) }

    let(:login_user) { publisher }
    let(:login_organisation) { organisation }

    before do
      create(:jobseeker_message, conversation: science_conversation, sender: jobseeker, content: "Looking forward to the interview")
      create(:jobseeker_message, conversation: math_conversation, sender: jobseeker, content: "Thank you for considering my application")

      visit publishers_candidate_messages_path
    end

    scenario "when searching by job title" do
      expect(page).to have_content("2 conversations")

      within("table tbody") do
        expect(page).to have_content("Science Teacher")
        expect(page).to have_content("Mathematics Teacher")
      end

      fill_in "keyword", with: "Science"
      click_button "Search"

      expect(page).to have_content("Showing 1 to 1 of 1 conversations for 'Science'")

      within("table tbody") do
        expect(page).to have_content("Science Teacher")
        expect(page).to have_no_content("Mathematics Teacher")
      end
    end

    scenario "when searching by message content" do
      fill_in "keyword", with: "interview"
      click_button "Search"

      expect(page).to have_content("Showing 1 to 1 of 1 conversations for 'interview'")

      within("table tbody") do
        expect(page).to have_content("Science Teacher")
        expect(page).to have_no_content("Mathematics Teacher")
      end
    end

    scenario "when searching with no results" do
      fill_in "keyword", with: "nonexistent"
      click_button "Search"

      expect(page).to have_content("Showing 0 to 0 of 0 conversations for 'nonexistent'")
      expect(page).to have_content("No messages yet.")
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

        expect(page).to have_content("Showing 1 to 1 of 1 conversations for 'Science'")

        within("table tbody") do
          expect(page).to have_content("Physics and Science") # Archived conversation
          expect(page).to have_no_content("Science Teacher") # Inbox conversation
          expect(page).to have_no_content("Mathematics Teacher")
        end
      end
    end

    context "when publisher is a MAT searching for messages" do
      let(:trust) { create(:trust) }
      let(:login_user) { mat_publisher }
      let(:login_organisation) { trust }
      let(:st_peters_school) { create(:school, school_groups: [trust]) }
      let(:st_johns_school) { create(:school, school_groups: [trust]) }
      let(:mat_publisher) { create(:publisher, organisations: [trust]) }

      # Create vacancies that are associated with BOTH the trust AND a member school
      # This reproduces the real-world scenario where a MAT publishes vacancies
      # that are also associated with individual schools
      let(:head_teacher_vacancy) { create(:vacancy, :live, job_title: "Head Teacher", organisations: [trust, st_peters_school]) }
      let(:deputy_head_vacancy) { create(:vacancy, :live, job_title: "Deputy Head", organisations: [trust, st_johns_school]) }

      let(:head_application) { create(:job_application, vacancy: head_teacher_vacancy, jobseeker: jobseeker, status: "interviewing") }
      let(:deputy_application) { create(:job_application, vacancy: deputy_head_vacancy, jobseeker: jobseeker, status: "interviewing") }

      let!(:head_conversation) { create(:conversation, job_application: head_application) }
      let!(:deputy_conversation) { create(:conversation, job_application: deputy_application) }

      before do
        # Create messages with common content that will be searched
        create(:jobseeker_message, conversation: head_conversation, sender: jobseeker, content: "Hi, looking forward to the interview")
        create(:jobseeker_message, conversation: deputy_conversation, sender: jobseeker, content: "Hi, thank you for the opportunity")

        visit current_path
      end

      it "does not show duplicate conversations when searching for common message content" do
        expect(page).to have_content("2 conversations")
        expect(candidate_names.count).to eq(2)

        # Search for common content that appears in both messages
        fill_in "keyword", with: "Hi"
        click_button "Search"

        expect(page).to have_content("Showing 1 to 2 of 2 conversations for 'Hi'")
        expect(candidate_names.count).to eq(2)

        within("table tbody") do
          expect(page).to have_content("Head Teacher")
          expect(page).to have_content("Deputy Head")
        end
      end
    end
  end

  def candidate_names
    page.all("table tbody tr > td")
        .to_a
        .in_groups_of(4)
        .map { |row| row[1].text }
  end
end
