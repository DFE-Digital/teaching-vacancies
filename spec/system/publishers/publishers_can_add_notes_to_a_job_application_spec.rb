require "rails_helper"

RSpec.describe "Publishers can add notes to a job application", js: true do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let!(:note) { create(:note, job_application: job_application, publisher: publisher, content: "This is a note") }
  let(:note_content) { "This is another note" }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  it "shows the current notes" do
    visit organisation_job_job_application_path(vacancy.id, job_application)
    click_on I18n.t("publishers.vacancies.job_applications.header.tabs.notes")

    expect(current_path).to eq(organisation_job_job_application_notes_path(vacancy.id, job_application))
    expect(page).to have_content(note.content)
  end

  it "allows notes to be added to job applications" do
    visit organisation_job_job_application_notes_path(vacancy.id, job_application)

    expect(page.has_field?("publishers-job-application-notes-form-content-field")).to eq(false)

    click_on I18n.t("buttons.add_note")

    expect(page.has_field?("publishers-job-application-notes-form-content-field")).to eq(true)

    fill_in "Add a note", with: ""
    click_on I18n.t("buttons.save")

    expect(page).to have_content(I18n.t("activemodel.errors.models.publishers/job_application/notes_form.attributes.content.blank"))

    fill_in "Add a note", with: note_content
    click_on I18n.t("buttons.save")

    expect(page).to have_content(note_content)
  end

  it "allows notes to be deleted" do
    visit organisation_job_job_application_notes_path(vacancy.id, job_application)

    expect(page).to have_content(note.content)
    click_on I18n.t("buttons.delete")

    expect(page).to_not have_content(note.content)
  end
end
