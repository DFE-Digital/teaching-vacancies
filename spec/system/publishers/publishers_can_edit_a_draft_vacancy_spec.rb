require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

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

        within "#job_details" do
          find("a").click
        end
        fill_in_job_location_form_fields([another_primary_school])
        click_on I18n.t("buttons.save_and_finish_later")

        expect(vacancy.reload.organisations).to contain_exactly(another_primary_school)

        within "#job_details" do
          find("a").click
        end
        fill_in_job_location_form_fields([primary_school, another_primary_school])
        click_on I18n.t("buttons.save_and_finish_later")

        expect(vacancy.reload.organisations).to contain_exactly(primary_school, another_primary_school)
      end

      context "when the new job location is the trust's central office" do
        scenario "the education phase has to be set" do
          within "#job_details" do
            find("a").click
          end
          fill_in_job_location_form_fields([trust])
          click_on I18n.t("buttons.save_and_finish_later")
          click_on "Complete job listing"

          expect(current_path).to eq(organisation_job_build_path(vacancy.id, :education_phases))
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
