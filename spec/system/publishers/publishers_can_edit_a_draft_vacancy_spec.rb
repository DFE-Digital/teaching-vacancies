require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "with a single school" do
    before { visit organisation_job_path(vacancy.id) }

    context "with a complete draft" do
      let(:vacancy) { create(:vacancy, :draft, :ect_suitable, job_roles: [:teacher], organisations: [primary_school], phases: %w[primary]) }

    scenario "can edit a draft" do
      click_review_page_change_link(section: "job_details", row: "job_role")

        fill_in_job_role_form_fields("teaching_assistant")
        click_on I18n.t("buttons.save_and_continue")

        expect(current_path).to eq(organisation_job_wizard_path(vacancy.id, :key_stages))
        fill_in_key_stages_form_fields(vacancy.key_stages_for_phases)
        click_on I18n.t("buttons.save_and_continue")

        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.save_and_continue")

        expect(current_path).to eq(organisation_job_review_path(vacancy.id))
        expect(vacancy.reload.job_roles).to contain_exactly("teaching_assistant", "teacher")
      end
    end
  end

  context "with a school group" do
    let(:vacancy) { create(:vacancy, :draft, :ect_suitable, job_roles: ["teacher"], organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }
    let(:another_primary_school) { create(:school, name: "Another primary school", phase: "primary") }
    let(:trust) { create(:trust, schools: [primary_school, another_primary_school]) }
    let(:organisation) { trust }

    before { visit organisation_job_path(vacancy.id) }

    context "when editing the job location" do
      scenario "successfully updating the job location" do
        within "#job_details" do
          find("a").click
        end

        fill_in_job_location_form_fields([another_primary_school])
        click_on I18n.t("buttons.save_and_finish_later")

        change_job_locations(vacancy, [another_primary_school])
        click_on I18n.t("buttons.save_and_continue")

        expect(current_path).to eq(organisation_job_review_path(vacancy.id))
        expect(vacancy.reload.organisations).to contain_exactly(another_primary_school)

        change_job_locations(vacancy, [primary_school, another_primary_school])
        click_on I18n.t("buttons.save_and_continue")

        expect(current_path).to eq(organisation_job_review_path(vacancy.id))
        expect(vacancy.reload.organisations).to contain_exactly(primary_school, another_primary_school)
      end

      context "when the new job location is the trust's central office" do
        scenario "the education phase has to be set" do
          change_job_locations(vacancy, [trust])
          click_on I18n.t("buttons.save_and_continue")

          expect(current_path).to eq(organisation_job_wizard_path(vacancy.id, :education_phases))
        end
      end

      context "when all of the job locations have 'not-applicable' phases" do
        let(:trust) { create(:trust, schools: [primary_school, not_applicable_school, another_not_applicable_school]) }
        let(:not_applicable_school) { create(:school, name: "Not applicable school", phase: "not_applicable") }
        let(:another_not_applicable_school) { create(:school, name: "Another not school", phase: "not_applicable") }

        scenario "the education phase has to be set" do
          within "#job_details" do
            find("a").click
          end
          fill_in_job_location_form_fields([not_applicable_school, another_not_applicable_school])
          displays_all_vacancy_organisations?([not_applicable_school, another_not_applicable_school])
          click_on I18n.t("buttons.save_and_continue")
          click_on I18n.t("buttons.save_and_continue")
          click_on I18n.t("buttons.save_and_continue")

          expect(current_path).to eq(organisation_job_wizard_path(vacancy.id, :education_phases))
        end
      end

      context "when the new organisation's education phase is associated with different key stages" do
        let(:secondary_school) { create(:school, name: "Second school", phase: "secondary") }
        let(:trust) { create(:trust, schools: [primary_school, secondary_school]) }

        scenario "key_stages has to be set again" do
          within "#job_details" do
            find("a").click
          end
          fill_in_job_location_form_fields([secondary_school])
          click_on I18n.t("buttons.save_and_continue")

          click_on I18n.t("buttons.save_and_continue")
          click_on I18n.t("buttons.save_and_continue")
          click_on I18n.t("buttons.save_and_continue")

          expect(current_path).to eq(organisation_job_wizard_path(vacancy.id, :key_stages))
          expect(page).to have_content(I18n.t("key_stages_errors.key_stages.inclusion"))
        end
      end
    end

    def displays_all_vacancy_organisations?(organisations)
      organisations.each { |organisation| expect(page).to have_content(organisation.name) }
    end
  end
end
