require "rails_helper"

RSpec.describe "Editing a published vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust, schools: [school1, school2]) }
  let(:school1) { create(:school, name: "First school") }
  let(:school2) { create(:school, name: "Second school") }
  let(:vacancy) { create(:vacancy, :central_office, :published, organisations: [school_group], job_roles: %w[teacher]) }

  before { login_publisher(publisher: publisher, organisation: school_group) }

  describe "#job_location" do
    scenario "can edit job location" do
      visit organisation_job_path(vacancy.id)

      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(school_group))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(
        I18n.t("publishers.organisations.readable_job_location.central_office"),
      )

      change_job_location(vacancy, "at_one_school", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
      fill_in_school_form_field(school1)
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_school"))
      expect(page).to have_content(full_address(school1))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(school1.name)

      change_job_location(vacancy, "at_one_school", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
      fill_in_school_form_field(school2)
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_school"))
      expect(page).to have_content(full_address(school2))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(school2.name)

      change_job_location(vacancy, "at_multiple_schools", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
      check school1.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
      check school2.name, name: "publishers_job_listing_schools_form[organisation_ids][]", visible: false
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_multiple_schools",
                                          organisation_type: "trust"))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq("More than one school (2)")

      change_job_location(vacancy, "central_office", "Multi-academy trust")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(school_group))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eq(
        I18n.t("publishers.organisations.readable_job_location.central_office"),
      )
    end

    context "when job_location is central_office and is updated to at_one_school" do
      scenario "job_location is not updated until the school is selected" do
        visit organisation_job_path(vacancy.id)

        expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
        expect(page).to have_content(full_address(school_group))
        expect(Vacancy.find(vacancy.id).readable_job_location).to eq(
          I18n.t("publishers.organisations.readable_job_location.central_office"),
        )

        change_job_location(vacancy, "at_one_school", "Multi-academy trust")

        visit organisation_job_path(vacancy.id)

        expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
        expect(page).to have_content(full_address(school_group))
        expect(Vacancy.find(vacancy.id).readable_job_location).to eq(
          I18n.t("publishers.organisations.readable_job_location.central_office"),
        )

        change_job_location(vacancy, "at_one_school", "Multi-academy trust")
        expect(page.current_path).to eq(organisation_job_build_path(vacancy.id, :schools))
        fill_in_school_form_field(school2)
        click_on I18n.t("buttons.update_job")

        expect(page.current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_school"))
        expect(page).to have_content(full_address(school2))
        expect(Vacancy.find(vacancy.id).readable_job_location).to eq(school2.name)
      end
    end
  end
end
