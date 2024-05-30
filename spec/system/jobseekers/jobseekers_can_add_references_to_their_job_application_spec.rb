require "rails_helper"

RSpec.describe "Jobseekers can add references to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before { login_as(jobseeker, scope: :jobseeker) }

  it "allows jobseekers to add references" do
    visit jobseekers_job_application_build_path(job_application, :references)

    expect(page).to have_content("No referees specified")

    click_on I18n.t("buttons.add_reference")
    expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :references))
    validates_step_complete(button: I18n.t("buttons.save_reference"))

    fill_in_reference

    click_on I18n.t("buttons.save_reference")

    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :references))
    expect(page).to have_content("Jim Referee")
  end

  context "when there is at least one reference" do
    let!(:reference) { create(:reference, name: "John", job_application: job_application) }

    it "allows jobseekers to delete references" do
      visit jobseekers_job_application_build_path(job_application, :references)

      click_on I18n.t("buttons.delete")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :references))
      expect(page).to have_content(I18n.t("jobseekers.job_applications.references.destroy.success"))
      expect(page).not_to have_content("John")
    end

    it "allows jobseekers to edit references" do
      visit jobseekers_job_application_build_path(job_application, :references)

      click_on I18n.t("buttons.change")

      fill_in "Name", with: ""
      validates_step_complete(button: I18n.t("buttons.save_reference"))

      fill_in "Name", with: "Jason"
      click_on I18n.t("buttons.save_reference")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :references))
      expect(page).not_to have_content("John")
      expect(page).to have_content("Jason")
    end
  end
end
