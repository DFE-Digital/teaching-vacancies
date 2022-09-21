require "rails_helper"

RSpec.describe "Editing a published vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust, schools: [school1, school2]) }
  let(:school1) { create(:school, name: "First school", phase: "primary") }
  let(:school2) { create(:school, name: "Second school", phase: "primary") }
  let(:vacancy) { create(:vacancy, :published, :teacher, :ect_suitable, organisations: [school_group], phases: %w[primary], key_stages: %w[ks1]) }

  before { login_publisher(publisher: publisher, organisation: school_group) }

  describe "#job_location" do
    scenario "can edit job location" do
      visit organisation_job_path(vacancy.id)

      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(school_group))
      displays_all_organisation_names?(vacancy)

      change_job_locations(vacancy, [school1])
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_location"))
      expect(page).to have_content(full_address(school1))
      displays_all_organisation_names?(vacancy)

      change_job_locations(vacancy, [school2])
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_one_location"))
      expect(page).to have_content(full_address(school2))
      displays_all_organisation_names?(vacancy)

      change_job_locations(vacancy, [school1, school2])
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.at_multiple_locations",
                                          organisation_type: "trust"))
      displays_all_organisation_names?(vacancy)

      change_job_locations(vacancy, [school_group])
      click_on I18n.t("buttons.save_and_continue")

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      expect(page).to have_content(full_address(school_group))
      displays_all_organisation_names?(vacancy)
    end
  end

  def displays_all_organisation_names?(vacancy)
    vacancy.organisations.each { |organisation| expect(page).to have_content(organisation.name) }
  end
end
