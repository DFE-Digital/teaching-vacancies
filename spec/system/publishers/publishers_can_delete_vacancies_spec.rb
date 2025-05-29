require "rails_helper"

RSpec.describe "School deleting vacancies" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let!(:vacancy) { create(:vacancy, :with_supporting_documents, :future_publish, organisations: [organisation]) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
    visit organisation_jobs_with_type_path(:pending)
    click_on vacancy.job_title
    click_on I18n.t("publishers.vacancies.show.heading_component.action.delete")
    click_on I18n.t("buttons.confirm_deletion")
  end

  after { logout }

  scenario "A school can delete a vacancy from a list, and supporting documents are deleted" do
    expect(page).to have_content(
      strip_tags(I18n.t("publishers.vacancies.destroy.success_html", job_title: vacancy.job_title)),
    )
    expect(vacancy.supporting_documents.count).to be_zero
  end
end
