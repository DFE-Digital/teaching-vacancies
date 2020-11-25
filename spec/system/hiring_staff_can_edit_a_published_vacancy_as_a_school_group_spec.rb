require "rails_helper"

RSpec.describe "Editing a published vacancy" do
  let(:school_group) { create(:trust) }
  let(:school_1) { create(:school, name: "First school") }
  let(:school_2) { create(:school, name: "Second school") }
  let(:session_id) { SecureRandom.uuid }
  let(:vacancy) { create(:vacancy, :at_central_office, :published) }

  before do
    vacancy.organisation_vacancies.create(organisation: school_group)
    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)
    stub_publishers_auth(uid: school_group.uid, session_id: session_id)
  end

  describe "#job_location" do
    scenario "can edit job location" do
      visit edit_organisation_job_path(vacancy.id)

      expect(page).to have_content(I18n.t("school_groups.job_location_heading.central_office"))
      expect(page).to have_content(full_address(school_group))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(
        I18n.t("publishers.organisations.readable_job_location.central_office"),
      )

      change_job_location(vacancy, "at_one_school")

      expect(page.current_path).to eql(organisation_job_build_path(vacancy.id, :schools))
      fill_in_school_form_field(school_1)
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("school_groups.job_location_heading.at_one_school"))
      expect(page).to have_content(full_address(school_1))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(school_1.name)

      change_job_location(vacancy, "at_one_school")

      expect(page.current_path).to eql(organisation_job_build_path(vacancy.id, :schools))
      fill_in_school_form_field(school_2)
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("school_groups.job_location_heading.at_one_school"))
      expect(page).to have_content(full_address(school_2))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(school_2.name)

      change_job_location(vacancy, "at_multiple_schools")

      expect(page.current_path).to eql(organisation_job_build_path(vacancy.id, :schools))
      check school_1.name, name: "schools_form[organisation_ids][]", visible: false
      check school_2.name, name: "schools_form[organisation_ids][]", visible: false
      click_on I18n.t("buttons.update_job")

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("school_groups.job_location_heading.at_multiple_schools",
                                          organisation_type: "trust"))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql("More than one school (2)")

      change_job_location(vacancy, "central_office")

      expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("school_groups.job_location_heading.central_office"))
      expect(page).to have_content(full_address(school_group))
      expect(Vacancy.find(vacancy.id).readable_job_location).to eql(
        I18n.t("publishers.organisations.readable_job_location.central_office"),
      )
    end

    context "when job_location is central_office and is updated to at_one_school" do
      scenario "job_location is not updated until the school is selected" do
        visit edit_organisation_job_path(vacancy.id)

        expect(page).to have_content(I18n.t("school_groups.job_location_heading.central_office"))
        expect(page).to have_content(full_address(school_group))
        expect(Vacancy.find(vacancy.id).readable_job_location).to eql(
          I18n.t("publishers.organisations.readable_job_location.central_office"),
        )

        change_job_location(vacancy, "at_one_school")

        click_on I18n.t("buttons.cancel_and_return")

        expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
        expect(page).to have_content(I18n.t("school_groups.job_location_heading.central_office"))
        expect(page).to have_content(full_address(school_group))
        expect(Vacancy.find(vacancy.id).readable_job_location).to eql(
          I18n.t("publishers.organisations.readable_job_location.central_office"),
        )

        change_job_location(vacancy, "at_one_school")
        expect(page.current_path).to eql(organisation_job_build_path(vacancy.id, :schools))
        fill_in_school_form_field(school_2)
        click_on I18n.t("buttons.update_job")

        expect(page.current_path).to eql(edit_organisation_job_path(vacancy.id))
        expect(page).to have_content(I18n.t("school_groups.job_location_heading.at_one_school"))
        expect(page).to have_content(full_address(school_2))
        expect(Vacancy.find(vacancy.id).readable_job_location).to eql(school_2.name)
      end
    end
  end
end
