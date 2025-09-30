require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  after { logout }

  context "with a single school" do
    before { visit organisation_job_path(vacancy.id) }

    context "with an incomplete draft" do
      let(:vacancy) { create(:draft_vacancy, :with_contract_details, :ect_suitable, job_roles: [], organisations: [primary_school], phases: %w[primary]) }

      before do
        within "#job_details" do
          find("a").click
        end
        click_on I18n.t("buttons.save_and_continue")
        # wait for page load
        find("form.new_publishers_job_listing_job_role_form")
      end

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"
      end

      it "can edit a draft", :a11y do
        fill_in_job_role_form_fields("teaching_assistant")
        click_on I18n.t("buttons.save_and_continue")

        # page load wait
        find("form.new_publishers_job_listing_key_stages_form")
        expect(current_path).to eq(organisation_job_wizard_path(vacancy.id, :key_stages))
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        fill_in_key_stages_form_fields(vacancy.key_stages_for_phases)
        progress_to_edit_page(:contract_information)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        progress_to_edit_page(:start_date)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        progress_to_edit_page(:pay_package)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        progress_to_edit_page(:about_the_role)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        progress_to_edit_page(:include_additional_documents)
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        progress_to_edit_page(:school_visits)
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        progress_to_edit_page(:visa_sponsorship)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        progress_to_edit_page(:important_dates)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        progress_to_edit_page(:applying_for_the_job)
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        progress_to_edit_page(:contact_details)
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner", "aria-allowed-attr"

        click_on I18n.t("buttons.save_and_continue")
        #  wait for page load
        find(".govuk-notification-banner")
        expect(current_path).to eq(organisation_job_review_path(vacancy.id))

        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

        expect(page).to have_content(DraftVacancy.find(vacancy.id).job_roles.first.humanize)
      end

      def progress_to_edit_page(page_name)
        click_on I18n.t("buttons.save_and_continue")
        # page load wait
        find("form.new_publishers_job_listing_#{page_name}_form")
        expect(current_path).to eq(organisation_job_wizard_path(vacancy.id, page_name))
      end
    end
  end

  context "with a school group" do
    let(:vacancy) { create(:draft_vacancy, :ect_suitable, job_roles: ["teacher"], organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }
    let(:another_primary_school) { create(:school, name: "Another primary school", phase: "primary") }
    let(:trust) { create(:trust, schools: [primary_school, another_primary_school]) }
    let(:organisation) { trust }

    before { visit organisation_job_path(vacancy.id) }

    context "when editing the job location" do
      before do
        within "#job_details" do
          find("a").click
        end
      end

      it "passes a11y", :a11y do
        expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"
      end

      scenario "successfully updating the job location" do
        fill_in_job_location_form_fields([another_primary_school])
        click_on I18n.t("buttons.save_and_finish_later")

        within "#job_details" do
          find("a").click
        end
        fill_in_job_location_form_fields([another_primary_school])
        click_on I18n.t("buttons.save_and_finish_later")

        expect(DraftVacancy.find(vacancy.id).organisations).to contain_exactly(another_primary_school)

        within "#job_details" do
          find("a").click
        end
        fill_in_job_location_form_fields([primary_school, another_primary_school])
        click_on I18n.t("buttons.save_and_finish_later")

        expect(DraftVacancy.find(vacancy.id).organisations).to contain_exactly(primary_school, another_primary_school)
      end

      context "when the new job location is the trust's central office" do
        scenario "the education phase has to be set" do
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
