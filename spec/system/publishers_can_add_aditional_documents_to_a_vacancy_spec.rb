require "rails_helper"

RSpec.describe "Publishers can add aditional documents to a vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  let!(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }

  scenario "can add an additional documents to a vacancy" do
    allow(Publishers::DocumentVirusCheck).to receive(:new).and_return(double(safe?: true))

    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_jobs_with_type_path
    click_on "Draft jobs"
    click_on vacancy.job_title
    click_review_page_change_link(section: "about_the_role", row: "include_additional_documents")
    expect(current_path).to eq(organisation_job_build_path(vacancy.id, :include_additional_documents))

    # Publisher can add a first additional document
    answer_include_additional_documents(true)
    expect(current_path).to eq(new_organisation_job_document_path(vacancy.id))

    add_document
    expect(current_path).to eq(organisation_job_documents_path(vacancy.id))

    # Having a first additional document, cannot submit an empty form for a second additional document
    answer_include_additional_documents(true)
    expect(current_path).to eq(new_organisation_job_document_path(vacancy.id))

    click_on I18n.t("buttons.save_and_continue")
    expect(current_path).to eq(organisation_job_documents_path(vacancy.id))
    expect(page).to have_content("There is a problem")

    # Can continue after attaching a document
    add_document
    expect(current_path).to eq(organisation_job_documents_path(vacancy.id))

    # Once decided not to include additional documents, can continue to the next step
    answer_include_additional_documents(false)
    expect(current_path).to eq(organisation_job_review_path(vacancy.id))
    expect(page).to have_content(vacancy.job_role.humanize)

    # Can publish the job listing
    click_on I18n.t("publishers.vacancies.show.heading_component.action.publish")
    expect(current_path).to eq(organisation_job_summary_path(vacancy.id))
  end

  def answer_include_additional_documents(include_additional_documents)
    vacancy.include_additional_documents = include_additional_documents
    fill_in_include_additional_documents_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")
  end

  def add_document
    page.attach_file("publishers_job_listing_documents_form[documents][]",
                     Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"))
    click_on I18n.t("buttons.save_and_continue")
  end
end
