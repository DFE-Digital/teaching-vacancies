require "rails_helper"

# reviewed - seems ok
RSpec.describe "Publishers can add notes to a job application" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:note_content) { "This is another note" }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "with a note" do
    let!(:note) { create(:note, job_application: job_application, publisher: publisher, content: "This is a note") }

    before do
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
    end

    it "shows the current notes" do
      expect(publisher_application_page).to be_displayed

      expect(page).to have_content(note.content)
    end

    it "allows notes to be deleted" do
      expect(publisher_application_page).to be_displayed

      click_on I18n.t("buttons.delete")
      # wait for action to complete
      expect(publisher_application_page.notification_banner.text).to eq("Success\nNote deleted")

      expect(page).to have_no_content(note.content)
    end
  end

  context "without a note" do
    before do
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
    end

    it "allows notes to be added to job applications" do
      expect(publisher_application_page).to be_displayed

      click_on I18n.t("buttons.save")

      expect(page).to have_content("Note did not save. Notes must not be blank or more than 150 words")

      fill_in "Add a note", with: "ABCDEFG"
      click_on I18n.t("buttons.save")

      # wait for action to complete
      expect(publisher_application_page.notification_banner.text).to eq("Success\nA note has been added")

      expect(page).to have_content("ABCDEFG")
    end
  end
end
