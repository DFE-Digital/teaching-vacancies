require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }

  let!(:vacancy) do
    create(:vacancy, :central_office, :draft, :teacher, :ect_suitable, organisations: [organisation])
  end

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "when a single school" do
    let(:organisation) { create(:school) }

    include_examples "provides an overview of the draft vacancy form"
  end

  context "when a school group" do
    let(:organisation) { create(:trust, schools: [school1, school2]) }
    let(:school1) { create(:school, name: "First school") }
    let(:school2) { create(:school, name: "Second school") }

    include_examples "provides an overview of the draft vacancy form"

    scenario "can edit job location" do
      visit organisation_job_review_path(vacancy.id)

      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(organisation))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(
        I18n.t("publishers.organisations.readable_job_location.central_office"),
      )
      expect(page).to_not have_css(".tabs-component")

      change_job_location(vacancy, "at_one_school", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
      fill_in_school_form_field(school1)
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_school"))
      expect(page).to have_content(full_address(school1))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(school1.name)

      change_job_location(vacancy, "at_one_school", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
      fill_in_school_form_field(school2)
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_school"))
      expect(page).to have_content(full_address(school2))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(school2.name)

      change_job_location(vacancy, "at_multiple_schools", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
      check school1.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
      check school2.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_multiple_schools",
                                          organisation_type: "trust"))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq("More than one school (2)")

      change_job_location(vacancy, "central_office", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(organisation))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(
        I18n.t("publishers.organisations.readable_job_location.central_office"),
      )
    end
  end
end
