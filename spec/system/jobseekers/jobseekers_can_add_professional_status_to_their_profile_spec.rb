require "rails_helper"

RSpec.describe "Jobseekers can add professional status to their profile" do
  let(:jobseeker) { create(:jobseeker) }
  let!(:profile) { create(:jobseeker_profile, jobseeker:, qualified_teacher_status: nil, qualified_teacher_status_year: nil) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after do
    logout
  end

  describe "adding professional status" do
    context "when jobseeker has qualified teacher status" do
      before { visit jobseekers_profile_path }

      it "allows jobseekers to add professional status information" do
        click_on "Add qualified teacher status"
        click_on "Save and continue"
        within "ul.govuk-list.govuk-error-summary__list" do
          expect(page).to have_link("Select yes if you have qualified teacher status (QTS)", href: "#jobseekers-profile-qualified-teacher-status-form-qualified-teacher-status-field-error")
        end
        within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
          choose "Yes"
        end
        click_on "Save and continue"
        within "ul.govuk-list.govuk-error-summary__list" do
          expect(page).to have_link("Enter the year your QTS was awarded", href: "#jobseekers-profile-qualified-teacher-status-form-qualified-teacher-status-year-field-error")
          expect(page).to have_link("Enter a teacher reference number (TRN)", href: "#jobseekers-profile-qualified-teacher-status-form-teacher-reference-number-field-error")
          expect(page).to have_link("Select yes and enter your teacher reference number (TRN). All teachers with QTS have a 7 digit TRN.", href: "#jobseekers-profile-qualified-teacher-status-form-has-teacher-reference-number-field-error")
          expect(page).to have_link("Select yes if you have completed your statutory induction year", href: "#jobseekers-profile-qualified-teacher-status-form-statutory-induction-complete-field-error")
        end
        within(find("fieldset", text: "Do you have a teacher reference number (TRN)?")) do
          choose "Yes"
        end
        fill_in "Year QTS was awarded", with: "2032"
        fill_in "What is your teacher reference number (TRN)?", with: "ABC"
        choose "Yes, I have completed a 1 or 2 year induction period"
        click_on "Save and continue"
        within "ul.govuk-list.govuk-error-summary__list" do
          expect(page).to have_link("The year your QTS was awarded must be the current year or in the past", href: "#jobseekers-profile-qualified-teacher-status-form-qualified-teacher-status-year-field-error")
          expect(page).to have_link("Enter a teacher reference number (TRN) that is 7 digits long", href: "#jobseekers-profile-qualified-teacher-status-form-teacher-reference-number-field-error")
        end
        fill_in "Year QTS was awarded", with: "2022"
        fill_in "What is your teacher reference number (TRN)?", with: "1234567"
        choose "Yes, I have completed a 1 or 2 year induction period"
        click_on "Save and continue"

        expect_page_to_have_professional_status_information(qts: "yes", year: "2022", trn: "1234567", statutory_induction_complete: "yes")
      end
    end

    context "when jobseeker does not have qualified teacher status" do
      before { visit jobseekers_profile_path }

      it "allows jobseekers to add professional status information" do
        click_on "Add qualified teacher status"
        click_on "Save and continue"
        within "ul.govuk-list.govuk-error-summary__list" do
          expect(page).to have_link("Select yes if you have qualified teacher status (QTS)", href: "#jobseekers-profile-qualified-teacher-status-form-qualified-teacher-status-field-error")
        end
        choose("jobseekers_profile_qualified_teacher_status_form[qualified_teacher_status]", option: "no")
        click_on "Save and continue"
        within "ul.govuk-list.govuk-error-summary__list" do
          expect(page).to have_link("Select yes and enter your teacher reference number (TRN). All teachers with QTS have a 7 digit TRN.", href: "#jobseekers-profile-qualified-teacher-status-form-has-teacher-reference-number-field-error")
        end
        within(find("fieldset", text: "Do you have a teacher reference number (TRN)?")) do
          choose "No"
        end
        click_on "Save and continue"
        expect_page_to_have_professional_status_information(qts: "no", year: nil, trn: nil, statutory_induction_complete: nil)
      end
    end
  end

  describe "editing professional status" do
    let!(:profile) { create(:jobseeker_profile, jobseeker:, qualified_teacher_status: "yes", qualified_teacher_status_year: "2020", teacher_reference_number: "7777777", statutory_induction_complete: "yes", has_teacher_reference_number: "yes") }

    before { visit jobseekers_profile_path }

    it "allows jobseekers to add professional status information" do
      expect_page_to_have_professional_status_information(qts: "yes", year: "2020", trn: "7777777", statutory_induction_complete: "yes")
      click_on "Change qualified teacher status"

      within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
        expect(find("#jobseekers-profile-qualified-teacher-status-form-qualified-teacher-status-yes-field")).to be_checked
      end
      within(find("fieldset", text: "Do you have a teacher reference number (TRN)?")) do
        expect(find("#jobseekers-profile-qualified-teacher-status-form-has-teacher-reference-number-yes-field")).to be_checked
      end
      expect(find("#jobseekers-profile-qualified-teacher-status-form-qualified-teacher-status-year-field").value).to eq("2020")
      within(find("fieldset", text: "Have you completed your statutory induction period?")) do
        expect(find("#jobseekers-profile-qualified-teacher-status-form-statutory-induction-complete-yes-field")).to be_checked
      end
      expect(find("#jobseekers-profile-qualified-teacher-status-form-teacher-reference-number-field").value).to eq("7777777")

      fill_in "Year QTS was awarded", with: "2000"
      fill_in "What is your teacher reference number (TRN)?", with: "1234567"
      choose "I'm on track to complete it"

      click_on "Save and continue"

      expect_page_to_have_professional_status_information(qts: "yes", year: "2000", trn: "1234567", statutory_induction_complete: "on_track")

      click_on "Change qualified teacher status"

      within(find("fieldset", text: "Do you have qualified teacher status (QTS)?")) do
        choose "No"
      end

      within(find("fieldset", text: "Do you have a teacher reference number (TRN)?")) do
        choose "No"
      end

      click_on "Save and continue"

      expect_page_to_have_professional_status_information(qts: "no", year: nil, trn: "", statutory_induction_complete: nil)
    end
  end

  def expect_page_to_have_professional_status_information(qts:, year:, trn:, statutory_induction_complete:)
    expect(page).to have_css(".govuk-summary-list__key", text: "Do you have qualified teacher status (QTS)?")
    expect(page).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_profile_qualified_teacher_status_form.qualified_teacher_status_options.#{qts}"))

    if qts == "yes"
      expect(page).to have_css(".govuk-summary-list__key", text: "Year QTS awarded")
      expect(page).to have_css(".govuk-summary-list__value", text: year)
    else
      expect(page).not_to have_css(".govuk-summary-list__key", text: "Year QTS awarded")
    end

    expect(page).to have_css(".govuk-summary-list__key", text: "Teacher reference number (TRN)")
    expect(page).to have_css(".govuk-summary-list__value", text: trn.present? ? trn : "None")

    return unless qts == "yes"

    expect(page).to have_css(".govuk-summary-list__key", text: "Have you completed your statutory induction period?")
    expect(page).to have_css(".govuk-summary-list__value", text: I18n.t("helpers.label.jobseekers_job_application_professional_status_form.statutory_induction_complete_options.#{statutory_induction_complete}"))
  end
end
