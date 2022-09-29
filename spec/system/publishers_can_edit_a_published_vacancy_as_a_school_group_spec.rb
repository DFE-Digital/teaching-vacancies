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

      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school1])
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school2])
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school1, school2])
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      verify_job_locations(vacancy)

      change_job_locations(vacancy, [school_group])
      click_on I18n.t("buttons.save_and_continue")

      fill_in_education_phases_form_fields(vacancy)
      click_on I18n.t("buttons.save_and_continue")

      check I18n.t("helpers.label.publishers_job_listing_job_details_form.key_stages_options.#{vacancy.key_stages.first}")
      click_on I18n.t("buttons.save_and_continue")

      expect(page.current_path).to eq(organisation_job_path(vacancy.id))
      verify_job_locations(vacancy)
    end
  end
end
