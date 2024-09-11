require "rails_helper"

RSpec.describe "Jobseekers can add qualifications to their profile" do
  let(:jobseeker) { create(:jobseeker) }
  let!(:profile) { create(:jobseeker_profile, jobseeker:) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  describe "changing personal details" do
    context "adding a qualification" do
      before { visit jobseekers_profile_path }

      it "allows jobseekers to add a graduate degree" do
        click_on "Add qualifications"
        select_qualification_category("Undergraduate degree")
        expect(page).to have_content(I18n.t("jobseekers.profiles.qualifications.new.heading.undergraduate"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
        fill_in_undergraduate_degree
        click_on I18n.t("buttons.save_qualification.one")
        expect(current_path).to eq(review_jobseekers_profile_qualifications_path)
        expect(page).to have_content("Undergraduate degree")
        expect(page).to have_content("University of Life")
        expect(page).not_to have_content("Subjects and grades")
        expect(page).not_to have_content("School, college, or other organisation")
      end

      it "allows jobseekers to add a custom qualification or course (category 'other')" do
        click_on "Add qualifications"
        select_qualification_category("Other qualification or course")
        expect(page).to have_content(I18n.t("jobseekers.profiles.qualifications.new.heading.other"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.one"))
        fill_in_other_qualification
        click_on I18n.t("buttons.save_qualification.one")
        expect(current_path).to eq(review_jobseekers_profile_qualifications_path)
        expect(page).to have_content("Superteacher Certificate")
        expect(page).to have_content("Teachers Academy")
        expect(page).to have_content("I expect to finish next year")
        expect(page).to have_content("Not finished yet")
        expect(page).not_to have_content("Grade")
        expect(page).not_to have_content("Year")
      end

      it "allows jobseekers to add a common secondary qualification" do
        click_on "Add qualifications"
        select_qualification_category("GCSEs")
        expect(page).to have_link(I18n.t("buttons.cancel"), href: jobseekers_profile_path)
        expect(page).to have_content(I18n.t("jobseekers.profiles.qualifications.new.heading.gcse"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
        fill_in_gcses
        click_on I18n.t("buttons.save_qualification.other")
        expect(current_path).to eq(review_jobseekers_profile_qualifications_path)
        expect(page).to have_content("GCSEs")
        expect(page).to have_content("Churchill School for Gifted Macaques")
        expect(page).to have_content("Maths – 110%")
        expect(page).to have_content("PE – 90%")
        expect(page).to have_content("2020")
        expect(page).not_to have_content("Not finished yet")
        expect(page).not_to have_content("Yes")
      end

      it "allows jobseekers to add a custom secondary qualification" do
        click_on "Add qualifications"
        select_qualification_category("Other secondary qualification")
        expect(page).to have_content(I18n.t("jobseekers.job_applications.qualifications.new.heading.other_secondary"))
        validates_step_complete(button: I18n.t("buttons.save_qualification.other"))
        fill_in_custom_secondary_qualifications
        click_on I18n.t("buttons.save_qualification.other")
        expect(current_path).to eq(review_jobseekers_profile_qualifications_path)
        expect(page).to have_content("Welsh Baccalaureate")
        expect(page).to have_content("Happy Rainbows School for High Achievers")
        expect(page).to have_content("Science – 5")
        expect(page).to have_content("German – 4")
        expect(page).to have_content("2020")
      end
    end
  end

  context "when editing a qualification" do
    context "when the qualification does not have qualification results" do
      let!(:qualification) do
        create(:qualification,
               category: "undergraduate",
               institution: "Life University",
               jobseeker_profile_id: profile.id)
      end

      it "allows jobseekers to edit the qualification" do
        visit review_jobseekers_profile_qualifications_path
        click_on "Change"
        fill_in "Awarding body", with: "University of Life"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).not_to have_content("Life University")
        expect(page).to have_content("University of Life")
      end
    end

    context "when the qualification has qualification results" do
      let!(:qualification) do
        create(:qualification,
               category: "other_secondary",
               institution: "John Mason School",
               jobseeker_profile_id: profile.id)
      end

      it "allows jobseekers to edit the qualification and its results" do
        visit review_jobseekers_profile_qualifications_path
        click_on "Change"
        fill_in "jobseekers_qualifications_secondary_other_form[qualification_results_attributes][0][subject]", with: "Hard Knocks"
        empty_second_qualification_result
        fill_in "School", with: "St Nicholas School"
        click_on I18n.t("buttons.save_and_continue")
        expect(page).not_to have_content("John")
        expect(page).to have_content("Nicholas")
        expect(page).to have_content("Hard Knocks")
      end
    end

    it "has an 'add another subject' link" do
      create(:qualification,
             category: "gcse",
             results_count: 1,
             jobseeker_profile_id: profile.id)

      visit review_jobseekers_profile_qualifications_path

      click_on "Add another subject"
      fill_in "Subject 2", with: "A second subject"
      fill_in "jobseekers_qualifications_secondary_common_form[qualification_results_attributes][1][grade]", with: "B"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_css(".detail-component", count: 1)
      subject_list = page.find("dt.govuk-summary-list__key", text: "Subjects and grades").sibling("dd")
      expect(subject_list).to have_css(".govuk-body", count: 2)
    end
  end

  def empty_second_qualification_result
    fill_in "jobseekers_qualifications_secondary_other_form[qualification_results_attributes][1][subject]", with: ""
    fill_in "jobseekers_qualifications_secondary_other_form[qualification_results_attributes][1][grade]", with: ""
  end
end
