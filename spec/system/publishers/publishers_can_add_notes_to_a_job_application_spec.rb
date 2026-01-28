require "rails_helper"

RSpec.describe "Publishers can add notes to a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  describe "on job application show page" do
    context "with a note" do
      let!(:note) { create(:note, job_application: job_application, publisher: publisher, content: "This is a note") }

      before do
        publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
      end

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean
      end

      it "shows the current notes" do
        expect(publisher_application_page).to be_displayed

        expect(page).to have_content(note.content)
      end

      it "allows notes to be deleted and show discarded at" do
        expect(publisher_application_page).to be_displayed

        click_on I18n.t("buttons.delete")
        # wait for action to complete
        expect(publisher_application_page.notification_banner.text).to eq("Success\nNote deleted")

        expect(page).to have_no_content(note.content)
        expect(page).to have_content("Note discarded at #{note.discarded_at}")
      end
    end

    describe "adding a note" do
      before do
        publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        fill_in "Add a note", with: note_content
        click_on I18n.t("buttons.save")
      end

      context "with too much content" do
        let(:note_content) { Faker::Lorem.question(word_count: 26) }

        it "handles errors when JS is not present" do
          expect(page).to have_content("A note must not be more than 150 characters")
        end
      end

      context "with ok content" do
        let(:note_content) { Faker::Lorem.question(word_count: 5) }

        it "allows notes to be added to job applications" do
          # wait for action to complete
          expect(publisher_application_page.notification_banner.text).to eq("Success\nA note has been added")

          expect(page).to have_content(note_content)
        end
      end
    end

    describe "on reference request page" do
      let(:referee) { create(:referee, job_application: job_application) }
      let(:reference_request) { create(:reference_request, referee: referee) }

      before do
        create(:job_reference, reference_request: reference_request)
      end

      context "with a note" do
        let!(:note) { create(:note, job_application: job_application, publisher: publisher, content: "This is a reference note") }

        before do
          publisher_ats_reference_request_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id, reference_request_id: reference_request.id)
        end

        it "shows the current notes" do
          expect(publisher_ats_reference_request_page).to be_displayed

          expect(page).to have_content(note.content)
        end

        it "allows notes to be deleted and redirects back to reference request page" do
          expect(publisher_ats_reference_request_page).to be_displayed

          click_on I18n.t("buttons.delete")

          expect(publisher_ats_reference_request_page).to be_displayed
          expect(page).to have_no_content(note.content)
        end
      end

      context "without a note" do
        before do
          publisher_ats_reference_request_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id, reference_request_id: reference_request.id)

          fill_in "Add a note", with: note_content
          click_on I18n.t("buttons.save_note")
        end

        context "with good note" do
          let(:note_content) { "New reference note" }

          it "allows notes to be added and redirects back to reference request page" do
            expect(publisher_ats_reference_request_page).to be_displayed
            expect(page).to have_content("New reference note")
          end
        end

        context "with too many characters" do
          let(:note_content) { Faker::Lorem.characters(number: 151) }

          it "copes with errors" do
            expect(page).to have_content("A note must not be more than 150 characters")
          end
        end
      end
    end

    describe "on self disclosure page" do
      before do
        create(:self_disclosure_request, job_application: job_application)
      end

      context "with a note" do
        let!(:note) { create(:note, job_application: job_application, publisher: publisher, content: "This is a self disclosure note") }

        before do
          publisher_ats_self_disclosure_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        end

        it "shows the current notes" do
          expect(publisher_ats_self_disclosure_page).to be_displayed

          expect(page).to have_content(note.content)
        end

        it "allows notes to be deleted and redirects back to self disclosure page" do
          expect(publisher_ats_self_disclosure_page).to be_displayed

          click_on I18n.t("buttons.delete")

          expect(publisher_ats_self_disclosure_page).to be_displayed
          expect(page).to have_no_content(note.content)
        end
      end

      context "without a note" do
        before do
          publisher_ats_self_disclosure_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
        end

        it "allows notes to be added and redirects back to self disclosure page" do
          fill_in "Add a note", with: "New self disclosure note"
          click_on I18n.t("buttons.save_note")

          expect(publisher_ats_self_disclosure_page).to be_displayed
          expect(page).to have_content("New self disclosure note")
        end

        it "copes with errors" do
          fill_in "Add a note", with: Faker::Lorem.characters(number: 151)
          click_on I18n.t("buttons.save_note")

          expect(page).to have_content("A note must not be more than 150 characters")
        end
      end
    end
  end
end
