require "rails_helper"

RSpec.describe "Jobseekers can add qualifications to their job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisations: [build(:school)]) }
  let(:job_application) { create(:job_application, :status_draft, jobseeker: jobseeker, vacancy: vacancy, qualifications: qualifications) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_job_application_build_path(job_application, :qualifications)
  end

  after { logout }

  context "adding a qualification" do
    let(:qualifications) { [] }

    before do
      click_on I18n.t("buttons.add_qualification")
      expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :qualifications))
    end

    it "allows jobseekers to add a graduate degree" do
      validates_step_complete(button: I18n.t("buttons.continue"))
      select_qualification_category("Undergraduate degree")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.undergraduate"))
      validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
      fill_in_undergraduate_degree
      click_on I18n.t("buttons.save_qualification.one")
      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :qualifications), ignore_query: true)
      expect(page).to have_content(I18n.t("buttons.add_another_qualification"))
      expect(page).to have_content("Undergraduate degree")
      expect(page).to have_content("University of Life")
      expect(page).not_to have_content("Subjects and grades")
      expect(page).not_to have_content("School, college, or other organisation")
    end

    it "allows jobseekers to add a custom qualification or course (category 'other')" do
      select_qualification_category("Other qualification")
      expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other"))
      validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
      fill_in_other_qualification
      click_on I18n.t("buttons.save_qualification.one")
      expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :qualifications), ignore_query: true)
      expect(page).to have_content("Superteacher Certificate")
      expect(page).to have_content("Teachers Academy")
      expect(page).to have_content("Superteaching")
      expect(page).to have_content("AXA")
      expect(page).to have_content("I expect to finish next year")
      expect(page).not_to have_content("Grade")
      expect(page).not_to have_content("Year")
    end
  end

  context "when editing a qualification" do
    context "when the qualification does not have qualification results" do
      let(:qualifications) do
        build_list(:qualification, 1,
                   category: "undergraduate",
                   institution: "Life University")
      end

      before do
        click_on I18n.t("buttons.change")
      end

      it "allows jobseekers to edit the qualification" do
        expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_job_application_build_path(job_application, :qualifications))
        fill_in "Awarding body", with: "University of Life"
        click_on I18n.t("buttons.save_qualification.one")
        expect(page).not_to have_content("Life University")
        expect(page).to have_content("University of Life")
      end
    end

    context "when the qualification has qualification results" do
      let!(:qualification) do
        create(:qualification,
               category: "a_level",
               institution: "John Mason School",
               job_application: job_application)
      end
      let(:qualifications) { [] }

      before { visit current_path }

      it "allows jobseekers to edit the qualification and its results" do
        click_on I18n.t("buttons.change")
        fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][0][subject]", with: "Hard Knocks"
        empty_second_qualification_result
        fill_in "School", with: "St Nicholas School"
        expect { click_on I18n.t("buttons.save_qualification.one") }.to change { qualification.qualification_results.count }.by(-1)
        expect(page).to have_current_path(jobseekers_job_application_build_path(job_application, :qualifications), ignore_query: true)
        expect(page).not_to have_content("John")
        expect(page).to have_content("Nicholas")
        expect(page).to have_content("Hard Knocks")
      end
    end

    context "with a GCSE" do
      let(:qualifications) { [] }

      it "has an 'add another subject' link" do
        create(:qualification,
               category: "gcse",
               results_count: 1,
               job_application: job_application)

        visit current_path

        expect(page).to have_css(".detail-component", count: 1)
        subject_list = page.find("dt.govuk-summary-list__key", text: "Subjects and grades").sibling("dd")
        expect(subject_list).to have_css(".govuk-body", count: 1)

        click_on "Add another subject"
        fill_in "Subject 2", with: "A second subject"
        fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][1][grade]", with: "B"
        click_on "Save qualifications"

        expect(page).to have_css(".detail-component", count: 1)
        subject_list = page.find("dt.govuk-summary-list__key", text: "Subjects and grades").sibling("dd")
        expect(subject_list).to have_css(".govuk-body", count: 2)
      end
    end
  end

  def empty_second_qualification_result
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][1][subject]", with: ""
    fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][1][grade]", with: ""
  end
end
