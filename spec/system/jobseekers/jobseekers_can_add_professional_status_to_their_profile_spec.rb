require "rails_helper"

RSpec.describe "Jobseekers can add professional status to their profile" do
  let(:jobseeker) { create(:jobseeker, jobseeker_profile: profile) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_profile_path
  end

  after do
    logout
  end

  describe "adding professional status" do
    let(:profile) { build(:jobseeker_profile, qualified_teacher_status: nil, qualified_teacher_status_year: nil) }

    it "passes a11y", :a11y do
      expect(page).to be_axe_clean
    end

    context "when on QTS page" do
      before do
        click_on "Add qualified teacher status"
      end

      it "passes a11y", :a11y do
        #  https://github.com/alphagov/govuk-frontend/issues/979
        expect(page).to be_axe_clean.skipping "aria-allowed-attr"
      end

      context "when jobseeker has qualified teacher status" do
        it "allows jobseekers to add professional status information" do
          click_on "Save and continue"
          within "ul.govuk-list.govuk-error-summary__list" do
            expect(page).to have_link("Select yes if you have qualified teacher status (QTS)", href: "#jobseekers-profiles-qualified-teacher-status-form-qualified-teacher-status-field-error")
          end
          within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
            choose "Yes"
          end
          click_on "Save and continue"
          within "ul.govuk-list.govuk-error-summary__list" do
            expect(page).to have_link("Enter the year your QTS was gained", href: "#jobseekers-profiles-qualified-teacher-status-form-qualified-teacher-status-year-field-error")
            expect(page).to have_link("Enter a teacher reference number (TRN) that is 7 digits long", href: "#jobseekers-profiles-qualified-teacher-status-form-teacher-reference-number-field-error")
            expect(page).to have_link("Select yes if you have completed your statutory induction year", href: "#jobseekers-profiles-qualified-teacher-status-form-is-statutory-induction-complete-field-error")
          end
          fill_in "Year QTS was gained", with: "2032"
          fill_in "What is your teacher reference number (TRN)?", with: "ABC"
          choose "Yes, I have completed my induction period"
          click_on "Save and continue"
          within "ul.govuk-list.govuk-error-summary__list" do
            expect(page).to have_link("The year your QTS was gained must be the current year or in the past", href: "#jobseekers-profiles-qualified-teacher-status-form-qualified-teacher-status-year-field-error")
            expect(page).to have_link("Enter a teacher reference number (TRN) that is 7 digits long", href: "#jobseekers-profiles-qualified-teacher-status-form-teacher-reference-number-field-error")
          end
          fill_in "Year QTS was gained", with: "2022"
          fill_in "What is your teacher reference number (TRN)?", with: "1234567"
          choose "No, I have not completed my induction period"
          fill_in "jobseekers-profiles-qualified-teacher-status-form-statutory-induction-complete-details-field", with: "Don't have time to explain"
          click_on "Save and continue"

          expect_page_to_have_professional_status_information(qts: "yes", year: "2022", trn: "1234567", statutory_induction_complete: "false", statutory_induction_complete_details: "Don't have time to explain")
        end
      end

      context "when jobseeker does not have qualified teacher status" do
        it "allows jobseekers to add professional status information" do
          click_on "Save and continue"
          within "ul.govuk-list.govuk-error-summary__list" do
            expect(page).to have_link("Select yes if you have qualified teacher status (QTS)", href: "#jobseekers-profiles-qualified-teacher-status-form-qualified-teacher-status-field-error")
          end
          choose("jobseekers_profiles_qualified_teacher_status_form[qualified_teacher_status]", option: "no")
          click_on "Save and continue"
          expect_page_to_have_professional_status_information(qts: "no", year: nil, trn: nil, statutory_induction_complete: nil)
        end
      end
    end
  end

  describe "editing professional status" do
    let(:profile) do
      build(:jobseeker_profile, qualified_teacher_status: "yes", qualified_teacher_status_year: "2020", teacher_reference_number: "7777777",
                                is_statutory_induction_complete: true)
    end

    it "allows jobseekers to add professional status information" do
      expect_page_to_have_professional_status_information(qts: "yes", year: "2020", trn: "7777777", statutory_induction_complete: "true")
      click_on "Change qualified teacher status"

      within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
        expect(find("#jobseekers-profiles-qualified-teacher-status-form-qualified-teacher-status-yes-field", visible: false)).to be_checked
      end
      expect(find("#jobseekers-profiles-qualified-teacher-status-form-qualified-teacher-status-year-field", visible: false).value).to eq("2020")
      within(find("fieldset", text: "Have you completed your induction period?")) do
        expect(find("#jobseekers-profiles-qualified-teacher-status-form-is-statutory-induction-complete-true-field", visible: false)).to be_checked
      end
      expect(find("#jobseekers-profiles-qualified-teacher-status-form-teacher-reference-number-field", visible: false).value).to eq("7777777")

      fill_in "Year QTS was gained", with: "2000"
      fill_in "What is your teacher reference number (TRN)?", with: "1234567"
      choose "No, I have not completed my induction period"
      fill_in "jobseekers-profiles-qualified-teacher-status-form-statutory-induction-complete-details-field", with: "I am working on it."

      click_on "Save and continue"

      expect_page_to_have_professional_status_information(qts: "yes", year: "2000", trn: "1234567", statutory_induction_complete: "false", statutory_induction_complete_details: "I am working on it.")

      click_on "Change qualified teacher status"

      within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
        choose "No"
      end

      click_on "Save and continue"

      expect_page_to_have_professional_status_information(qts: "no", year: nil, trn: "1234567", statutory_induction_complete: nil)
    end
  end

  def expect_page_to_have_professional_status_information(qts:, year:, trn:, statutory_induction_complete:, statutory_induction_complete_details: nil)
    expect(page).to have_css(".govuk-summary-list__key", text: "Do you have qualified teacher status (QTS)?")
    expect(page).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_profiles_qualified_teacher_status_form.qualified_teacher_status_options.#{qts}"))

    if qts == "yes"
      expect(page).to have_css(".govuk-summary-list__key", text: "Year QTS gained")
      expect(page).to have_css(".govuk-summary-list__value", text: year)
    else
      expect(page).not_to have_css(".govuk-summary-list__key", text: "Year QTS gained")
    end

    expect(page).to have_css(".govuk-summary-list__key", text: "Teacher reference number (TRN)")
    expect(page).to have_css(".govuk-summary-list__value", text: trn.present? ? trn : "None")

    return unless qts == "yes"

    expect(page).to have_css(".govuk-summary-list__key", text: "Have you completed your induction period?")
    expect(page).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_job_application_professional_status_form.is_statutory_induction_complete_options.#{statutory_induction_complete}"))

    if statutory_induction_complete_details.present? && statutory_induction_complete == "no"
      expect(page).to have_css(".govuk-summary-list__key", text: "Additional induction details")
      expect(page).to have_css(".govuk-summary-list__value", text: statutory_induction_complete_details)
    end
  end
end
