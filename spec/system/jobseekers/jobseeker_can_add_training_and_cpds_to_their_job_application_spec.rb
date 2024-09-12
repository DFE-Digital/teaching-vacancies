require "rails_helper"

RSpec.describe "Jobseeker can add training and cpds to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  after { logout }

  context "adding training" do
    it "allows jobseeker to add training" do
      visit jobseekers_job_application_build_path(job_application, :training_and_cpds)
      click_on "Add training"

      click_on "Save and continue"

      expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
      within(".govuk-error-summary__body") do
        expect(page).to have_link("Enter the name of the course or training", href: "#jobseekers-training-and-cpd-form-name-field-error")
        expect(page).to have_link("Enter the name of the provider of the training", href: "#jobseekers-training-and-cpd-form-provider-field-error")
        expect(page).to have_link("Enter the year the course or training was awarded", href: "#jobseekers-training-and-cpd-form-year-awarded-field-error")
      end

      fill_in_and_submit_training_form("Rock climbing instructional course", "Training org", "A", "2024")

      expect(current_path).to eq("/jobseekers/job_applications/#{job_application.id}/build/training_and_cpds")

      expect_page_to_have_values("Rock climbing instructional course", "Training org", "A", "2024")
    end
  end

  context "editing training" do
    let!(:training_and_cpds) { create(:training_and_cpd, job_application: job_application) }

    it "allows jobseeker to edit existing training" do
      visit jobseekers_job_application_build_path(job_application, :training_and_cpds)
      expect_page_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020")

      click_link "Change"

      fill_in_and_submit_training_form("Choir singing instructional course", "Training org", "A", "2024")

      expect(current_path).to eq("/jobseekers/job_applications/#{job_application.id}/build/training_and_cpds")

      expect_page_to_have_values("Choir singing instructional course", "Training org", "A", "2024")
      expect_page_not_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020")
    end
  end

  context "deleting training" do
    let!(:training_and_cpds) { create(:training_and_cpd, job_application: job_application) }

    it "allows jobseeker to edit existing training" do
      visit jobseekers_job_application_build_path(job_application, :training_and_cpds)
      expect_page_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020")

      click_link "Delete"

      expect(page).to have_css("div.govuk-notification-banner__content p.govuk-notification-banner__heading", text: "Training deleted")

      expect(current_path).to eq("/jobseekers/job_applications/#{job_application.id}/build/training_and_cpds")

      expect_page_not_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020")
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

  def expect_page_not_to_have_values(name, provider, grade, year)
    expect(page).not_to have_css(".govuk-summary-list__value", text: name)
    expect(page).not_to have_css(".govuk-summary-list__value", text: provider)
    expect(page).not_to have_css(".govuk-summary-list__value", text: grade)
    expect(page).not_to have_css(".govuk-summary-list__value", text: year)
  end
end
