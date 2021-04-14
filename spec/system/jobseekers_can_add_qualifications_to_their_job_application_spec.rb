# expect(page).to have_content(I18n.t("jobseekers.job_applications.build.qualifications.heading"))
# expect(page).to have_content("No qualifications specified")
# click_on I18n.t("buttons.save_and_continue")
# expect(page).not_to have_content("There is a problem")
# click_on I18n.t("buttons.back")
# # 1. Graduate degrees
# click_on I18n.t("buttons.add_qualification")
# validates_step_complete(button: I18n.t("buttons.continue"))
# choose "Undergraduate degree"
# click_on I18n.t("buttons.continue")
# expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
# validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
# fill_in_undergraduate_degree
# click_on I18n.t("buttons.save_qualification.one")
# # TODO: expect the qualification to be displayed
# # 2. Generic 'other' qualification
# click_on I18n.t("buttons.add_another_qualification")
# choose "Other qualification or course"
# click_on I18n.t("buttons.continue")
# expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other"))
# validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
# fill_in_other_qualification
# click_on I18n.t("buttons.save_qualification.one")
# # TODO: expect the qualification to be displayed
# # 3. Common secondary qualifications
# click_on I18n.t("buttons.add_another_qualification")
# choose "GCSE"
# click_on I18n.t("buttons.continue")
# expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.gcse"))
# validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
# fill_in_gcse
# # TODO: fill_in_another_gcse
# click_on I18n.t("buttons.save_qualification.other")
# # TODO: expect the qualification to be displayed
# #
# # TODO: Can delete and edit GCSE
# # click_on I18n.t("buttons.add_another_qualification")
# # choose "GCSE"
# # click_on I18n.t("buttons.continue")
# # delete_gcse
# # edit_other_gcse
# # click_on I18n.t("buttons.save_qualification")
# # expect the qualifications to be deleted and edited
# #
# # 4. Other secondary qualification
# click_on I18n.t("buttons.add_another_qualification")
# choose "Other secondary qualification"
# click_on I18n.t("buttons.continue")
# expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other_secondary"))
# validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
# fill_in_secondary_qualification
# # TODO: fill_in_another_secondary_qualification
# click_on I18n.t("buttons.save_qualification.other")
# # TODO: expect the qualification to be displayed
# click_on I18n.t("buttons.save_and_continue")

require "rails_helper"

RSpec.describe "Jobseekers can add qualifications to their job application" do
  # Test:
  # Adding all sorts of qualifications
  # Pending (todo): adding more than one qualification at once
  # The display of these qualifications (grouping is tested on JobApplication)
  # That they can be deleted
  # Pending (todo): editing

  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows jobseekers to add qualifications" do
    visit jobseekers_job_application_build_path(job_application, :qualifications)

    expect(page).to have_content("No qualifications specified")

    click_on I18n.t("buttons.add_qualification")
    validates_step_complete(button: I18n.t("buttons.continue"))
    select_qualification_category("Undergraduate degree")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
    validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
    fill_in_undergraduate_degree
    click_on I18n.t("buttons.save_qualification.one")
    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
    expect(page).to have_content("Undergraduate degree")
    expect(page).to have_content("University of Life")
    expect(page).not_to have_content("Subjects and grades")
    expect(page).not_to have_content("School, college, or other organisation")

    click_on I18n.t("buttons.add_another_qualification")
    select_qualification_category("Other qualification or course")
    expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other"))
    validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
    fill_in_other_qualification
    click_on I18n.t("buttons.save_qualification.one")
    expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
    expect(page).to have_content("Superteacher Certificate")
    expect(page).to have_content("Teachers Academy")
    expect(page).to have_content("I expect to finish next year")
    expect(page).not_to have_content("Grade")
    expect(page).not_to have_content("Year")

    # TODO: more qualification types
  end

  # context "when there is at least one reference" do
  #   let!(:reference) { create(:reference, name: "John", job_application: job_application) }
  #
  #   it "allows jobseekers to delete references" do
  #     visit jobseekers_job_application_build_path(job_application, :references)
  #
  #     click_on I18n.t("buttons.delete")
  #
  #     expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :references))
  #     expect(page).to have_content(I18n.t("jobseekers.job_applications.references.destroy.success"))
  #     expect(page).not_to have_content("John")
  #   end
  #
  #   it "allows jobseekers to edit references" do
  #     visit jobseekers_job_application_build_path(job_application, :references)
  #
  #     click_on I18n.t("buttons.edit")
  #
  #     fill_in "Name", with: ""
  #     click_on I18n.t("buttons.save_reference")
  #
  #     expect(page).to have_content("There is a problem")
  #
  #     fill_in "Name", with: "Jason"
  #     click_on I18n.t("buttons.save_reference")
  #
  #     expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :references))
  #     expect(page).not_to have_content("John")
  #     expect(page).to have_content("Jason")
  #   end
  # end
end
