require "rails_helper"

RSpec.describe "Publishers can add additional documents to a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  let!(:vacancy) { create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    publisher_vacancy_page.load(vacancy_id: vacancy.id)
  end

  after { logout }

  scenario "can add an additional documents to a vacancy" do
    allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))

    visit organisation_job_build_path(vacancy.id, :include_additional_documents)

    # Publisher can add a first additional document
    publisher_include_additional_documents_page.include_documents_yes.click
    click_on I18n.t("buttons.save_and_continue")
    expect(publisher_add_document_page).to be_displayed

    expect(publisher_add_document_page).to be_displayed
    click_on I18n.t("buttons.save_and_continue")

    expect(publisher_vacancy_documents_page).to be_displayed
    expect(page).to have_content("There is a problem")
    expect(publisher_vacancy_documents_page.errors.map(&:text)).to eq(["Select an additional document"])

    click_on "Back"

    # Once decided not to include additional documents, can continue to the next step
    answer_include_additional_documents(false)

    expect(page).to have_current_path(organisation_job_review_path(vacancy.id), ignore_query: true)
    expect(page).to have_content(vacancy.job_roles.first.humanize)

    # Can publish the job listing
    click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
    expect(page).to have_current_path(organisation_job_summary_path(vacancy.id), ignore_query: true)
  end

  def answer_include_additional_documents(include_additional_documents)
    fill_in_include_additional_documents_form_fields(include_additional_documents)
    click_on I18n.t("buttons.save_and_continue")
  end
end
