require "rails_helper"

RSpec.describe "Publishers can edit a draft vacancy" do
  let(:publisher) { create(:publisher) }
  let(:primary_school) { create(:school, name: "Primary school", phase: "primary") }
  let(:organisation) { primary_school }

  before { login_publisher(publisher: publisher, organisation: organisation) }

  context "when a single school" do
    let!(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }

    before do
      visit organisation_path(organisation)
      click_on "Draft jobs"
      click_on vacancy.job_title
    end

    scenario "indicates that you're reviewing a draft" do
      has_complete_draft_vacancy_review_heading?(vacancy)
    end

    scenario "can edit a draft" do
      click_review_page_change_link(section: "job_details", row: "job_role")

      vacancy.job_role = "teaching_assistant"
      fill_in_job_role_form_fields(vacancy)

      click_on I18n.t("buttons.save_and_continue")

      expect(current_path).to eq(organisation_job_review_path(vacancy.id))
      expect(page).to have_content(vacancy.job_role.humanize)
    end

    scenario "going back to the review page after clicking change link" do
      click_review_page_change_link(section: "job_details", row: "job_role")

      click_on I18n.t("buttons.back")

      expect(current_path).to eq(organisation_job_path(vacancy.id))
    end
  end

  context "when a school group" do
    let!(:vacancy) { create(:vacancy, :draft, :teacher, :ect_suitable, organisations: [primary_school], phases: %w[primary], key_stages: %w[ks1]) }
    let(:another_primary_school) { create(:school, name: "Another primary school", phase: "primary") }
    let(:trust) { create(:trust, schools: [primary_school, another_primary_school]) }
    let(:organisation) { trust }

    before { visit organisation_job_path(vacancy.id) }

    context "when editing the job location" do
      scenario "successfully updating the job location" do
        expect(page).to have_content(full_address(primary_school))
        displays_all_vacancy_organisations?(vacancy)

        expect(page).to_not have_css(".tabs-component")

        change_job_locations(vacancy, [another_primary_school])
        click_on I18n.t("buttons.save_and_continue")

        expect(current_path).to eq(organisation_job_review_path(vacancy.id))
        verify_job_locations(vacancy)

        change_job_locations(vacancy, [primary_school, another_primary_school])
        click_on I18n.t("buttons.save_and_continue")

        expect(current_path).to eq(organisation_job_review_path(vacancy.id))
        verify_job_locations(vacancy)
      end

      context "when the new job location is the trust's central office" do
        scenario "the education phase has to be set" do
          change_job_locations(vacancy, [trust])
          click_on I18n.t("buttons.save_and_continue")

          expect(current_path).to eq(organisation_job_build_path(vacancy.id, :education_phases))
        end
      end

      context "when all of the job locations have 'not-applicable' phases" do
        let(:trust) { create(:trust, schools: [primary_school, not_applicable_school, another_not_applicable_school]) }
        let(:not_applicable_school) { create(:school, name: "Not applicable school", phase: "not_applicable") }
        let(:another_not_applicable_school) { create(:school, name: "Another not school", phase: "not_applicable") }

        scenario "the education phase has to be set" do
          change_job_locations(vacancy, [not_applicable_school, another_not_applicable_school])
          displays_all_vacancy_organisations?(vacancy)
          click_on I18n.t("buttons.save_and_continue")

          expect(current_path).to eq(organisation_job_build_path(vacancy.id, :education_phases))
        end
      end

      context "when the new organisation's education phase is associated with different key stages" do
        let(:secondary_school) { create(:school, name: "Second school", phase: "secondary") }
        let(:trust) { create(:trust, schools: [primary_school, secondary_school]) }

        scenario "key_stages has to be set again" do
          change_job_locations(vacancy, [secondary_school])
          click_on I18n.t("buttons.save_and_continue")

          vacancy.phases = %w[secondary]

          click_on I18n.t("buttons.save_and_continue")

          expect(current_path).to eq(organisation_job_build_path(vacancy.id, :key_stages))
          expect(page).to have_content(I18n.t("key_stages_errors.key_stages.inclusion"))
        end
      end
    end

    def displays_all_vacancy_organisations?(vacancy)
      vacancy.organisations.each { |organisation| expect(page).to have_content(organisation.name) }
    end
  end
end
