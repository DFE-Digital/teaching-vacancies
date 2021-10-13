require "rails_helper"

RSpec.describe "School deleting vacancies" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :with_supporting_documents, :future_publish, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit jobs_with_type_organisation_path(:pending)
    click_on vacancy.job_title
  end

  scenario "A school can delete a vacancy from a list" do
    click_on I18n.t("buttons.delete")
    click_on I18n.t("buttons.confirm_deletion")

    expect(page).to have_content(
      strip_tags(I18n.t("publishers.vacancies.destroy.success_html", job_title: vacancy.job_title)),
    )
  end

  scenario "Deleting a vacancy triggers deletion of its supporting documents" do
    click_on I18n.t("buttons.delete")
    click_on I18n.t("buttons.confirm_deletion")

    expect(vacancy.supporting_documents.count).to be_zero
  end

  scenario "Notifies the Google index service" do
    expect_any_instance_of(Publishers::Vacancies::BaseController).to receive(:remove_google_index).with(vacancy)

    click_on I18n.t("buttons.delete")
    click_on I18n.t("buttons.confirm_deletion")
  end
end
