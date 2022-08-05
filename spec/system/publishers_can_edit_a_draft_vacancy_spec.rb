require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school) { create(:school, name: "First school") }
  let(:school2) { create(:school, name: "Second school") }
  let(:trust) { create(:trust, schools: [school, school2]) }
  let(:organisation) { trust }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "when a single school" do
    let!(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [school]) }

    include_examples "provides an overview of the draft vacancy form"
  end

  context "when a school group" do
    let!(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, :central_office, organisations: [trust]) }

    include_examples "provides an overview of the draft vacancy form"

    scenario "can edit job location" do
      visit organisation_job_review_path(vacancy.id)

      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(trust))
      displays_all_vacancy_organisations?(vacancy)

      expect(page).to_not have_css(".tabs-component")

      change_job_locations(vacancy, [school])
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_location"))
      expect(page).to have_content(full_address(school))
      displays_all_vacancy_organisations?(vacancy)

      change_job_locations(vacancy, [school2])
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_location"))
      expect(page).to have_content(full_address(school2))
      displays_all_vacancy_organisations?(vacancy)

      change_job_locations(vacancy, [school, school2])
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_multiple_locations",
                                          organisation_type: "trust"))
      displays_all_vacancy_organisations?(vacancy)

      change_job_locations(vacancy, [trust])
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(trust))
      displays_all_vacancy_organisations?(vacancy)
    end

    def displays_all_vacancy_organisations?(vacancy)
      vacancy.organisations.each { |organisation| expect(page).to have_content(organisation.name) }
    end
  end
end
