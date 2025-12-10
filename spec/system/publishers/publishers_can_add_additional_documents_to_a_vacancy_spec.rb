require "rails_helper"

RSpec.describe "Publishers can add additional documents to a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  let!(:vacancy) { create(:draft_vacancy, :ect_suitable, job_roles: ["teacher"], organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_job_build_path(vacancy.id, :include_additional_documents)
    # wait for page load
    find("label[for='publishers-job-listing-include-additional-documents-form-include-additional-documents-true-field']")
    find("footer")
  end

  after { logout }

  it "passes a11y", :a11y do
    expect(page).to be_axe_clean
  end

  scenario "can add an additional documents to a vacancy" do
    allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))

    # Publisher can add a first additional document
    publisher_include_additional_documents_page.include_documents_yes.click
    click_on I18n.t("buttons.save_and_continue")
    expect(publisher_add_document_page).to be_displayed

    add_document
    expect(publisher_vacancy_documents_page).to be_displayed

    # Having a first additional document, cannot submit an empty form for a second additional document
    publisher_vacancy_documents_page.add_another_document_yes_radio.click
    click_on I18n.t("buttons.save_and_continue")
    expect(publisher_add_document_page).to be_displayed

    click_on I18n.t("buttons.save_and_continue")
    expect(publisher_vacancy_documents_page).to be_displayed
    expect(page).to have_content("There is a problem")
    expect(publisher_vacancy_documents_page.errors.map(&:text)).to eq(["Select an additional document"])

    # Can continue after attaching a document
    add_document
    expect(publisher_vacancy_documents_page).to be_displayed

    # Once decided not to include additional documents, can continue to the next step
    publisher_vacancy_documents_page.add_another_document_no_radio.click
    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_review_path(vacancy.id))
    expect(page).to have_content(vacancy.job_roles.first.humanize)

    # Can publish the job listing
    click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
    expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
  end

  def add_document
    page.attach_file("publishers_job_listing_documents_form[supporting_documents][]",
                     Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"))
    click_on I18n.t("buttons.save_and_continue")
  end
end
