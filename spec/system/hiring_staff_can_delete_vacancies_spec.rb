require "rails_helper"

RSpec.describe "School deleting vacancies" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :future_publish, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    stub_document_deletion_of_vacancy
    visit jobs_with_type_organisation_path(:pending)
  end

  scenario "A school can delete a vacancy from a list" do
    within(".card-component#vacancy_#{vacancy.id}") do
      click_on "Delete"
    end

    expect(page).to have_content(
      strip_tags(I18n.t("publishers.vacancies.destroy.success_html", job_title: vacancy.job_title)),
    )
    expect(page).to have_content(I18n.t("publishers.no_vacancies_component.heading"))
  end

  scenario "Deleting a vacancy triggers deletion of its supporting documents" do
    expect(vacancy).to receive(:delete_documents)

    within(".card-component#vacancy_#{vacancy.id}") do
      click_on "Delete"
    end
  end

  scenario "Notifies the Google index service" do
    expect_any_instance_of(Publishers::Vacancies::BaseController).to receive(:remove_google_index).with(vacancy)

    within(".card-component#vacancy_#{vacancy.id}") do
      click_on "Delete"
    end
  end

  private

  def stub_document_deletion_of_vacancy
    # Stub vacancy lookup so that the controller uses these tests' vacancy objects
    # to wrap the vacancy, instead of creating its own new vacancy object.
    # We need to use a `vacancy` object created in the test so that we can stub out the method
    # Vacancy#delete_documents, which otherwise will attempt HTTP connections.
    allow_any_instance_of(Publishers::Vacancies::BaseController).to receive_message_chain(
      :current_organisation, :all_vacancies, :find
    ).and_return(vacancy)
    allow(vacancy).to receive(:delete_documents).and_return(nil)
  end
end
