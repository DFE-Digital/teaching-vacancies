require "rails_helper"

RSpec.describe "Jobseekers can add training to their profile" do
  let(:jobseeker) { create(:jobseeker) }
  let!(:profile) { create(:jobseeker_profile, jobseeker:) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  describe "changing training details" do
    context "adding training" do
      before { visit jobseekers_profile_path }

      it "allows jobseekers to add training" do
        click_on "Add training"
        click_on "Save and continue"

        expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
        within(".govuk-error-summary__body") do
          expect(page).to have_link("Enter the name of the course or training", href: "#jobseekers-training-and-cpd-form-name-field-error")
          expect(page).to have_link("Enter the name of the provider of the training", href: "#jobseekers-training-and-cpd-form-provider-field-error")
          expect(page).to have_link("Enter the year the course or training was awarded", href: "#jobseekers-training-and-cpd-form-year-awarded-field-error")
        end

        fill_in_and_submit_training_form("Rock climbing instructional course", "TeachTrain ltd", "A", "2024")

        expect_page_to_have_values("Rock climbing instructional course", "TeachTrain ltd", "A", "2024")

        click_link "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect_page_to_have_values("Rock climbing instructional course", "TeachTrain ltd", "A", "2024")
      end
    end

    context "editing training" do
      before do
        create(:training_and_cpd, jobseeker_profile: profile)
        visit jobseekers_profile_path
      end

      it "allows jobseeker to edit training" do
        expect_page_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020")

        within(".govuk-summary-card__title-wrapper", text: "Rock climbing") do
          click_link("Change")
        end

        fill_in_and_submit_training_form("Teaching piano to young adults", "PianoWorx", "A", "2021")

        expect_page_to_have_values("Teaching piano to young adults", "PianoWorx", "A", "2021")

        click_link "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect_page_to_have_values("Teaching piano to young adults", "PianoWorx", "A", "2021")
      end
    end

    context "deleting training" do
      before do
        create(:training_and_cpd, jobseeker_profile: profile)
        visit jobseekers_profile_path
      end

      it "allows users to delete training" do
        expect_page_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020")

        within(".govuk-summary-card__title-wrapper", text: "Rock climbing") do
          click_link("Delete")
        end

        expect(page).to have_content "Confirm that you want to delete this training and development"

        click_button "Delete training"

        expect(page).to have_current_path(review_jobseekers_profile_training_and_cpds_path)

        expect(page).to have_css("h2.govuk-notification-banner__title", text: "Success")
        expect(page).to have_css(".govuk-notification-banner__content", text: "Training deleted")

        expect(page).to_not have_css(".govuk-summary-list__value", text: "Rock climbing")
        expect(page).to_not have_css(".govuk-summary-list__value", text: "TeachTrainLtd")
        expect(page).to_not have_css(".govuk-summary-list__value", text: "Pass")
        expect(page).to_not have_css(".govuk-summary-list__value", text: "2020")
      end
    end
  end

  def fill_in_and_submit_training_form(name, provider, grade, year)
    fill_in "Name", with: name
    fill_in "Training provider", with: provider
    fill_in "Grade", with: grade
    fill_in "Year awarded", with: year
    click_on "Save and continue"
  end

  def expect_page_to_have_values(name, provider, grade, year)
    expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
    expect(page).to have_css(".govuk-summary-list__value", text: name)

    expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
    expect(page).to have_css(".govuk-summary-list__value", text: provider)

    expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
    expect(page).to have_css(".govuk-summary-list__value", text: grade)

    expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
    expect(page).to have_css(".govuk-summary-list__value", text: year)
  end
end
