require "rails_helper"

RSpec.describe "Jobseekers can add qualifications to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: build(:school) }]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy) }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
  end

  context "adding a qualification" do
    context "when JavaScript is not required" do
      before do
        visit jobseekers_job_application_build_path(job_application, :qualifications)
        click_on I18n.t("buttons.add_qualification")
      end

      it "allows jobseekers to add a graduate degree" do
        validates_step_complete(button: I18n.t("buttons.continue"))
        choose "Undergraduate degree"
        click_on I18n.t("buttons.continue")
        expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
        fill_in_undergraduate_degree
        click_on I18n.t("buttons.save_qualification.one")
        expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
        expect(page).to have_content(I18n.t("buttons.add_another_qualification"))
        expect(page).to have_content("Undergraduate degree")
        expect(page).to have_content("University of Life")
        expect(page).not_to have_content("Subjects and grades")
        expect(page).not_to have_content("School, college, or other organisation")
      end

      it "allows jobseekers to add a custom qualification or course (category 'other')" do
        choose "Other qualification or course"
        click_on I18n.t("buttons.continue")
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
      end
    end

    context "when JavaScript is required", js: true do
      it "allows jobseekers to add a common secondary qualification" do
        visit new_jobseekers_job_application_qualification_path(job_application, category: "gcse")
        expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.gcse"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
        fill_in_gcse
        click_on I18n.t("buttons.add_another_subject")
        fill_in "Subject 2", with: "Circus Tricks"
        fill_in "jobseekers_job_application_details_qualifications_secondary_common_form[grade2]", with: "Distinction"
        click_on I18n.t("buttons.save_qualification.other")
        expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
        expect(page).to have_content("GCSEs")
        expect(page).to have_content("Churchill School for Gifted Macaques")
        expect(page).to have_content("2020")
        expect(page).to have_content("Maths – 110%")
        expect(page).to have_content("Circus Tricks – Distinction")
      end

      it "allows jobseekers to add a custom secondary qualification" do
        visit new_jobseekers_job_application_qualification_path(job_application, category: "other_secondary")
        expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other_secondary"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
        fill_in_secondary_qualification
        click_on I18n.t("buttons.add_another_subject")
        fill_in "Subject 2", with: "Defence Against the Dark Arts"
        fill_in "jobseekers_job_application_details_qualifications_secondary_other_form[grade2]", with: "Pass"
        click_on I18n.t("buttons.save_qualification.other")
        expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
        expect(page).to have_content("Welsh Baccalaureates")
        expect(page).to have_content("Happy Rainbows School for High Achievers")
        expect(page).to have_content("2020")
        expect(page).to have_content("Science – 5")
        expect(page).to have_content("Defence Against the Dark Arts – Pass")
      end
    end
  end

  context "when there is exactly one qualification" do
    let!(:qualification) do
      create(:qualification,
             category: "other_secondary",
             institution: "John Mason School",
             job_application: job_application)
    end

    it "allows jobseekers to edit a single qualification" do
      visit jobseekers_job_application_build_path(job_application, :qualifications)

      click_on I18n.t("buttons.edit")

      fill_in "School", with: "St Nicholas School"
      click_on I18n.t("buttons.save_qualification.one")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).not_to have_content("John")
      expect(page).to have_content("Nicholas")
    end
  end

  context "when there is a group of more than one qualifications" do
    let(:subjects) { %w[Art Science] }
    let(:grades) { %w[A B] }
    let!(:qualifications) do
      create_list(:qualification, 2,
                  category: "other_secondary",
                  institution: "John Mason School",
                  name: "O Level",
                  job_application: job_application,
                  year: 1970) do |qualification, index|
        qualification.update_columns(subject: subjects[index], grade: grades[index])
      end
    end

    it "allows jobseekers to delete the qualifications as a group" do
      visit jobseekers_job_application_build_path(job_application, :qualifications)

      click_on I18n.t("buttons.delete")

      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.destroy.success.other"))
      expect(page).not_to have_content("John Mason School")
    end

    it "allows jobseekers to add qualifications to a group", js: true do
      visit jobseekers_job_application_build_path(job_application, :qualifications)

      click_on I18n.t("buttons.edit")

      expect(current_path).to eq(edit_jobseekers_job_application_qualifications_path(job_application))

      expect(page).to have_field("Subject 1", with: "Art")
                  .and have_field("jobseekers_job_application_details_qualifications_secondary_other_form[grade1]",
                                  with: qualifications.first.grade)
                  .and have_field("Subject 2", with: "Science")
                  .and have_field("jobseekers_job_application_details_qualifications_secondary_other_form[grade2]",
                                  with: qualifications.second.grade)

      click_on I18n.t("buttons.add_another_subject")

      fill_in "Subject 3", with: "Subjectology"
      fill_in "jobseekers_job_application_details_qualifications_secondary_other_form[grade3]", with: "40%"

      click_on I18n.t("buttons.save_qualification.other")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).to have_content("Art – A")
                  .and have_content("Science – B")
                  .and have_content("Subjectology – 40%")
    end

    it "allows jobseekers to edit qualifications within a group" do
      visit jobseekers_job_application_build_path(job_application, :qualifications)

      click_on I18n.t("buttons.edit")

      fill_in "Subject 2", with: "Computer literacy"
      fill_in "Year qualification(s) was/were awarded", with: "2000"

      click_on I18n.t("buttons.save_qualification.other")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).not_to have_content("Science")
      expect(page).not_to(have_content("1970"))
      expect(page).to have_content("Computer literacy – B")
                  .and have_content("2000")
    end

    it "allows jobseekers to delete a qualification from a group", js: true do
      visit jobseekers_job_application_build_path(job_application, :qualifications)

      click_on I18n.t("buttons.edit")
      click_on("delete_2")
      click_on I18n.t("buttons.save_qualification.other")
      expect(current_path).to eq(jobseekers_job_application_build_path(job_application, :qualifications))
      expect(page).not_to have_content("Science")
    end
  end
end
