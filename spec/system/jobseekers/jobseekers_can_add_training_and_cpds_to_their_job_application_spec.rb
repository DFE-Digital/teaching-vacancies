require "rails_helper"

RSpec.describe "Jobseeker can add training and cpds to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy, training_and_cpds: training_and_cpds) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_build_path(job_application, :training_and_cpds)
  end

  after { logout }

  describe "adding training" do
    let(:training_and_cpds) { [] }

    it "allows jobseeker to add training" do
      click_on "Add training"

      expect(page).to be_axe_clean.skipping "region", "landmark-no-duplicate-banner"

      click_on "Save and continue"

      expect(page).to have_css("h2.govuk-error-summary__title", text: "There is a problem")
      within(".govuk-error-summary__body") do
        expect(page).to have_link("Enter the name of the course or training", href: "#jobseekers-training-and-cpd-form-name-field-error")
        expect(page).to have_link("Enter the year the course or training was awarded", href: "#jobseekers-training-and-cpd-form-year-awarded-field-error")
      end

      fill_in_and_submit_training_form("Rock climbing instructional course", "Training org", "A", "2024", "6 months")

      expect(page).to have_current_path("/jobseekers/job_applications/#{job_application.id}/build/training_and_cpds", ignore_query: true)

      expect_page_to_have_values("Rock climbing instructional course", "Training org", "A", "2024", "6 months")
    end
  end

  describe "editing training" do
    let(:training_and_cpds) { build_list(:training_and_cpd, 1) }

    it "allows jobseeker to edit existing training" do
      expect_page_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020", "1 year")

      click_link "Change"

      fill_in_and_submit_training_form("Choir singing instructional course", "Training org", "A", "2024", "6 months")

      expect(page).to have_current_path("/jobseekers/job_applications/#{job_application.id}/build/training_and_cpds", ignore_query: true)

      expect_page_to_have_values("Choir singing instructional course", "Training org", "A", "2024", "6 months")
      expect_page_not_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020", "1 year")
    end
  end

  describe "deleting training" do
    let(:training_and_cpds) { build_list(:training_and_cpd, 1) }

    it "allows jobseeker to edit existing training" do
      expect_page_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020", "1 year")

      click_link "Delete"

      expect(page).to have_css("div.govuk-notification-banner__content p.govuk-notification-banner__heading", text: "Training deleted")

      expect(page).to have_current_path("/jobseekers/job_applications/#{job_application.id}/build/training_and_cpds", ignore_query: true)

      expect_page_not_to_have_values("Rock climbing", "TeachTrainLtd", "Pass", "2020", "1 year")
    end
  end

  def fill_in_and_submit_training_form(name, provider, grade, year, course_length)
    fill_in "Name", with: name
    fill_in "Training provider", with: provider
    fill_in "Grade", with: grade
    fill_in "Date completed", with: year
    fill_in "Course length", with: course_length
    click_on "Save and continue"
  end

  def expect_page_to_have_values(name, provider, grade, year, course_length)
    expect(page).to have_css(".govuk-summary-list__key", text: "Name of course or training")
    expect(page).to have_css(".govuk-summary-list__value", text: name)

    expect(page).to have_css(".govuk-summary-list__key", text: "Training provider")
    expect(page).to have_css(".govuk-summary-list__value", text: provider)

    expect(page).to have_css(".govuk-summary-list__key", text: "Grade (optional)")
    expect(page).to have_css(".govuk-summary-list__value", text: grade)

    expect(page).to have_css(".govuk-summary-list__key", text: "Date completed")
    expect(page).to have_css(".govuk-summary-list__value", text: year)

    expect(page).to have_css(".govuk-summary-list__key", text: "Course length")
    expect(page).to have_css(".govuk-summary-list__value", text: course_length)
  end

  def expect_page_not_to_have_values(name, provider, grade, year, course_length)
    expect(page).to have_no_css(".govuk-summary-list__value", text: name)
    expect(page).to have_no_css(".govuk-summary-list__value", text: provider)
    expect(page).to have_no_css(".govuk-summary-list__value", text: grade)
    expect(page).to have_no_css(".govuk-summary-list__value", text: year)
    expect(page).to have_no_css(".govuk-summary-list__value", text: course_length)
  end
end
