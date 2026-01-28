require "rails_helper"

RSpec.describe "Publishers can interview for a religious vacancy" do
  let(:publisher) { create(:publisher, email: "publisher@contoso.com") }
  let(:job_application) do
    create(:job_application, :status_interviewing,
           :with_religious_referee,
           create_references: true,
           religious_reference_request: build(:religious_reference_request),
           notes: build_list(:note, 1),
           vacancy: vacancy, jobseeker: jobseeker)
  end
  let(:vacancy) { create(:vacancy, :catholic, :expired, organisations: [school], publisher: publisher) }
  let(:action_needed) { "Action needed" }
  let(:organisation) { create(:local_authority, schools: [school]) }
  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker, email: "jobseeker@contoso.com") }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    publisher_ats_pre_interview_checks_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
  end

  after { logout }

  it "displays action needed" do
    within "#religious_reference" do
      expect(page).to have_content action_needed
    end
  end

  describe "editing a religious reference" do
    before do
      within "#religious_reference" do
        find("a").click
      end
    end

    it "allows the reference to be marked as requested" do
      click_on "Mark as requested"
      within "#religious_reference" do
        expect(page).to have_content "pending"
      end
    end

    describe "completing a religious reference" do
      before do
        click_on "Mark as requested"
        within "#religious_reference" do
          find("a").click
        end
      end

      it "allows the reference to be marked as complete" do
        click_on "Mark as complete"
        within "#religious_reference" do
          expect(page).to have_content "completed"
        end
      end
    end

    describe "adding a note" do
      before do
        fill_in "Add a note", with: note_content
        click_on "Save note"
      end

      context "with too much content" do
        let(:note_content) { Faker::Lorem.characters(number: 151) }

        it "has errors" do
          expect(page).to have_content("Notes must not be blank or more than 150 characters")
        end
      end

      context "with ok content" do
        let(:note_content) { Faker::Ancient.hero }

        it "allows notes to be added without disturbing the flow" do
          find ".govuk-notification-banner"
          expect(page).to have_content "A note has been added"
          expect(page).to have_content note_content
          expect(page).to have_current_path edit_organisation_job_job_application_religious_reference_path(vacancy.id, job_application.id)
        end
      end
    end
  end
end
