require "rails_helper"

RSpec.describe "Editing a published vacancy" do
  let(:publisher) { create(:publisher) }
  let(:school_group) { create(:trust, schools: [school1, school2]) }
  let(:school1) { create(:school, name: "First school", phase: "primary") }
  let(:school2) { create(:school, name: "Second school", phase: "primary") }
  let(:vacancy) { create(:vacancy, :published, :ect_suitable, job_roles: ["teacher"], organisations: [school_group], phases: %w[primary], key_stages: %w[ks1]) }

  before { login_publisher(publisher: publisher, organisation: school_group) }

  describe "#job_location" do
    it "can edit job location" do
      visit organisation_job_path(vacancy.id)

      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school1])
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_path(vacancy.id), ignore_query: true)
      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school2])
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_path(vacancy.id), ignore_query: true)
      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school1, school2])
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_path(vacancy.id), ignore_query: true)
      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school_group])
      click_on I18n.t("buttons.save_and_continue")

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      fill_in_key_stages_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_current_path(organisation_job_path(vacancy.id), ignore_query: true)
      verify_job_locations(vacancy)
    end
  end
end
