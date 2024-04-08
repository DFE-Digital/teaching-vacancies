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
        click_on "Save"

        expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
        within(".govuk-error-summary__body") do
          expect(page).to have_link("Enter the name of the course or training", href: "#jobseekers-training-and-cpd-form-name-field-error")
          expect(page).to have_link("Enter the name of the provider of the training", href: "#jobseekers-training-and-cpd-form-provider-field-error")
          expect(page).to have_link("Enter the year the course or training was awarded", href: "#jobseekers-training-and-cpd-form-year-awarded-field-error")
        end

        fill_in "Name", with: "Rock climbing instructional course"
        fill_in "Training provider", with: "TeachTrain ltd"
        fill_in "Grade", with: "A"
        fill_in "Year awarded", with: "2024"
        click_on "Save"

        within(all(".govuk-summary-list__row")[0]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
          expect(page).to have_css(".govuk-summary-list__value", text: "Rock climbing instructional course")
        end

        within(all(".govuk-summary-list__row")[1]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
          expect(page).to have_css(".govuk-summary-list__value", text: "TeachTrain ltd")
        end

        within(all(".govuk-summary-list__row")[2]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
          expect(page).to have_css(".govuk-summary-list__value", text: "A")
        end

        within(all(".govuk-summary-list__row")[3]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
          expect(page).to have_css(".govuk-summary-list__value", text: "2024")
        end

        click_link "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
        expect(page).to have_css(".govuk-summary-list__value", text: "Rock climbing instructional course")

        expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
        expect(page).to have_css(".govuk-summary-list__value", text: "TeachTrain ltd")

        expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
        expect(page).to have_css(".govuk-summary-list__value", text: "A")

        expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
        expect(page).to have_css(".govuk-summary-list__value", text: "2024")
      end
    end

    context "editing training" do
      before do
        create(:training_and_cpd, jobseeker_profile: profile)
        visit jobseekers_profile_path
      end

      it "allows jobseeker to edit training" do
        expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
        expect(page).to have_css(".govuk-summary-list__value", text: "Rock climbing")

        expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
        expect(page).to have_css(".govuk-summary-list__value", text: "TeachTrainLtd")

        expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
        expect(page).to have_css(".govuk-summary-list__value", text: "Pass")

        expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
        expect(page).to have_css(".govuk-summary-list__value", text: "2020")

        within('.govuk-summary-card__title-wrapper', text: 'Rock climbing') do
          click_link('Change')
        end

        fill_in "Name", with: "Teaching piano to young adults"
        fill_in "Training provider", with: "PianoWorx"
        fill_in "Grade", with: "A"
        fill_in "Year awarded", with: "2021"
        click_on "Save"

        within(all(".govuk-summary-list__row")[0]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
          expect(page).to have_css(".govuk-summary-list__value", text: "Teaching piano to young adults")
        end

        within(all(".govuk-summary-list__row")[1]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
          expect(page).to have_css(".govuk-summary-list__value", text: "PianoWorx")
        end

        within(all(".govuk-summary-list__row")[2]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
          expect(page).to have_css(".govuk-summary-list__value", text: "A")
        end

        within(all(".govuk-summary-list__row")[3]) do
          expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
          expect(page).to have_css(".govuk-summary-list__value", text: "2021")
        end

        click_link "Return to profile"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
        expect(page).to have_css(".govuk-summary-list__value", text: "Teaching piano to young adults")

        expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
        expect(page).to have_css(".govuk-summary-list__value", text: "PianoWorx")

        expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
        expect(page).to have_css(".govuk-summary-list__value", text: "A")

        expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
        expect(page).to have_css(".govuk-summary-list__value", text: "2021")
      end
    end

    context "deleting training" do
      before do
        create(:training_and_cpd, jobseeker_profile: profile)
        visit jobseekers_profile_path
      end

      it "allows users to delete training" do
        expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
        expect(page).to have_css(".govuk-summary-list__value", text: "Rock climbing")

        expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
        expect(page).to have_css(".govuk-summary-list__value", text: "TeachTrainLtd")

        expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
        expect(page).to have_css(".govuk-summary-list__value", text: "Pass")

        expect(page).to have_css(".govuk-summary-list__key", text: "Year awarded")
        expect(page).to have_css(".govuk-summary-list__value", text: "2020")

        within('.govuk-summary-card__title-wrapper', text: 'Rock climbing') do
          click_link('Delete')
        end

        expect(page).to have_content "Confirm that you want to delete this training and development"

        click_button "Delete training"

        expect(page).to have_current_path(jobseekers_profile_path)

        expect(page).to have_css("h2.govuk-notification-banner__title", text: "Success")
        expect(page).to have_css(".govuk-notification-banner__content", text: "Training deleted")

        expect(page).to_not have_css(".govuk-summary-list__value", text: "Rock climbing")
        expect(page).to_not have_css(".govuk-summary-list__value", text: "TeachTrainLtd")
        expect(page).to_not have_css(".govuk-summary-list__value", text: "Pass")
        expect(page).to_not have_css(".govuk-summary-list__value", text: "2020")
      end
    end
  end
end
