require "rails_helper"

RSpec.describe "School deleting vacancies" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :with_supporting_documents, :future_publish, organisation_vacancies_attributes: [{ organisation: organisation }]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
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
    within(".card-component#vacancy_#{vacancy.id}") do
      click_on "Delete"
    end

    expect(vacancy.supporting_documents.count).to be_zero
  end

  scenario "Notifies the Google index service" do
    expect_any_instance_of(Publishers::Vacancies::BaseController).to receive(:remove_google_index).with(vacancy)

    within(".card-component#vacancy_#{vacancy.id}") do
      click_on "Delete"
    end
  end
end
