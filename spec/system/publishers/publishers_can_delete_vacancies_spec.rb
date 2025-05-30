require "rails_helper"

RSpec.describe "School deleting vacancies" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }

  before do
    login_publisher(publisher: publisher, organisation: organisation)
  end

  after { logout }

  context "with a future publish vacancy" do
    let!(:vacancy) { create(:vacancy, :with_supporting_documents, :future_publish, organisations: [organisation]) }

    before do
      visit organisation_jobs_with_type_path(:pending)
      click_on vacancy.job_title
    end

    scenario "Deleting a vacancy triggers deletion of its supporting documents" do
      click_on I18n.t("publishers.vacancies.show.heading_component.action.delete")
      click_on I18n.t("buttons.confirm_deletion")

      expect(page).to have_content(
        strip_tags(I18n.t("publishers.vacancies.destroy.success_html", job_title: vacancy.job_title)),
      )
      expect(vacancy.supporting_documents.count).to be_zero
    end
  end

  context "with a draft vacancy" do
    let!(:vacancy) { create(:draft_vacancy, organisations: [organisation]) }

    before do
      visit organisation_jobs_with_type_path(:draft)
      click_on vacancy.job_title
    end

    it "destroys the record" do
      click_on I18n.t("publishers.vacancies.show.heading_component.action.delete")

      expect {
        click_on I18n.t("buttons.confirm_deletion")
      }.to change(Vacancy, :count).by(-1)
    end
  end
end
