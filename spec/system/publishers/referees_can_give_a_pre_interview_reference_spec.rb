require "rails_helper"

RSpec.describe "Publishers can select a job application for interview" do
  let(:publisher) { create(:publisher) }
  let(:organisation) { create(:school) }
  let(:vacancy) { create(:vacancy, :expired, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) do
    create(:job_application, :status_submitted,
           referees: [
             build(:referee, is_most_recent_employer: true),
             build(:referee, is_most_recent_employer: false),
           ],
           vacancy: vacancy, jobseeker: jobseeker)
  end

  describe "referee flow" do
    let(:referee) { job_application.referees.first }
    let(:reference_request) { create(:reference_request, referee: referee) }

    before do
      create(:job_reference, reference_request: reference_request)
      referee_can_give_reference_page.load(reference_id: reference_request.id, token: reference_request.token)
    end

    context "without an answer" do
      before do
        click_on I18n.t("buttons.continue")
      end

      it "displays an error" do
        expect(referee_can_give_reference_page.errors.map(&:text))
          .to eq(["Select yes if you can provide the candidate with a reference"])
      end
    end

    context "when the referee cannot give a reference" do
      let(:reason) { Faker::Lorem.paragraph }

      before do
        choose I18n.t("helpers.label.referees_can_give_reference_form.can_give_reference_options.false")
      end

      it "shows as not given" do
        fill_in "referees-can-give-reference-form-not-provided-reason-field", with: reason
        click_on I18n.t("buttons.continue")
        expect(page).to have_current_path(no_reference_reference_build_index_path(reference_request.id))
        expect(reference_request.job_reference.reload).to be_complete
        expect(reference_request.job_reference.can_give_reference).to be(false)
        expect(reference_request.job_reference.not_provided_reason).to eq(reason)

        run_with_publisher_and_organisation(publisher, organisation) do
          publisher_ats_pre_interview_checks_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)
          expect(page).to have_content "Declined"
        end
      end
    end

    context "when giving a reference" do
      before do
        choose I18n.t("helpers.label.referees_can_give_reference_form.can_give_reference_options.true")
        click_on I18n.t("buttons.continue")
        # wait for page load
        find("form[action='/references/#{reference_request.id}/build/can_share']")
      end

      #  have to use JS driver for send_keys support
      it "displays the fit_and_proper page followed by the employment_reference page", :a11y do
        expect(page).to be_axe_clean

        choose I18n.t("helpers.label.referees_can_share_reference_form.is_reference_sharable_options.false")
        click_on I18n.t("buttons.continue")
        # click through fit-and-proper-person blurb
        # wait for page
        find("form[action='/references/#{reference_request.id}/build/fit_and_proper_persons']")
        expect(page).to be_axe_clean
        click_on I18n.t("buttons.continue")

        expect(referee_employment_reference_page).to be_displayed
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
        referee_employment_reference_page.currently_employed_no.click
        referee_employment_reference_page.reemploy_current_yes.click
        referee_employment_reference_page.reemploy_any_yes.click

        fill_in "referees_employment_reference_form[how_do_you_know_the_candidate]", with: Faker::Lorem.paragraph
        fill_in "referees_employment_reference_form[reason_for_leaving]", with: Faker::Lorem.paragraph
        fill_in "referees_employment_reference_form[would_reemploy_current_reason]", with: Faker::Lorem.paragraph
        fill_in "referees_employment_reference_form[would_reemploy_any_reason]", with: Faker::Lorem.paragraph

        referee_employment_reference_page.employment_start_day.send_keys "2"
        referee_employment_reference_page.employment_start_month.send_keys "0"
        referee_employment_reference_page.employment_start_year.send_keys "2007"

        referee_employment_reference_page.employment_end_day.send_keys "2"
        referee_employment_reference_page.employment_end_month.send_keys "0"
        referee_employment_reference_page.employment_end_year.send_keys "2008"

        click_on I18n.t("buttons.continue")
        expect(referee_employment_reference_page.errors.map(&:text)).to eq(["Enter a date in the correct format", "Enter a date in the correct format"])

        referee_employment_reference_page.employment_start_month.send_keys "3"
        referee_employment_reference_page.employment_end_month.send_keys "3"

        click_on I18n.t("buttons.continue")

        expect(referee_reference_information_page).to be_displayed
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
        referee_reference_information_page.under_investigation_yes.click
        referee_reference_information_page.warnings_yes.click
        referee_reference_information_page.allegations_yes.click
        referee_reference_information_page.not_fit_to_practice_yes.click
        referee_reference_information_page.able_to_undertake_role_yes.click
        fill_in "referees_reference_information_form[under_investigation_details]", with: Faker::Lorem.paragraph
        fill_in "referees_reference_information_form[warning_details]", with: Faker::Lorem.paragraph

        click_on I18n.t("buttons.continue")

        expect(referee_how_would_you_rate1_page).to be_displayed
        expect(page).to be_axe_clean
        referee_how_would_you_rate1_page.outstanding_punctuality.click
        referee_how_would_you_rate1_page.outstanding_working_relationships.click
        referee_how_would_you_rate1_page.outstanding_customer_care.click
        referee_how_would_you_rate1_page.outstanding_adapt_to_change.click
        click_on I18n.t("buttons.continue")

        expect(referee_how_would_you_rate2_page).to be_displayed
        expect(page).to be_axe_clean
        referee_how_would_you_rate2_page.outstanding_deal_with_conflict.click
        referee_how_would_you_rate2_page.outstanding_prioritise_workload.click
        referee_how_would_you_rate2_page.outstanding_team_working.click
        referee_how_would_you_rate2_page.outstanding_communication.click
        click_on I18n.t("buttons.continue")

        expect(referee_how_would_you_rate3_page).to be_displayed
        expect(page).to be_axe_clean
        referee_how_would_you_rate3_page.outstanding_problem_solving.click
        referee_how_would_you_rate3_page.outstanding_general_attitude.click
        referee_how_would_you_rate3_page.outstanding_technical_competence.click
        referee_how_would_you_rate3_page.outstanding_leadership.click
        click_on I18n.t("buttons.continue")

        expect(referee_referee_details_page).to be_displayed
        expect(page).to be_axe_clean

        referee_referee_details_page.complete_and_accurate_checkbox.click
        # last click to go to the confirmation page
        click_on I18n.t("buttons.confirm_and_submit")

        # wait for page load
        find(".govuk-panel")
        expect(reference_request.job_reference.reload).to be_complete
        expect(page).to have_current_path(completed_reference_build_index_path(reference_request.id))
      end
    end
  end
end
