require "rails_helper"

RSpec.shared_examples "a successful search" do
  context "when searching for teacher jobs" do
    let(:keyword) { "Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("a", text: "Remove this filter Teacher")
    end

    it "displays page 1 jobs" do
      expect(page).to have_css(".search-results > .search-results__item", count: 2)
      expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 1, to: 2, total: 6, type: "results"))
    end

    context "when navigating between pages" do
      it "displays page 3 jobs" do
        within ".govuk-pagination" do
          click_on "3"
        end

        expect(page).to have_css(".search-results > .search-results__item", count: 2)
        expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 5, to: 6, total: 6, type: "results"))
      end
    end
  end

  context "when searching for maths jobs" do
    let(:per_page) { 100 }
    let(:keyword) { "Maths Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("a", text: "Remove this filter Teacher")
    end

    it "displays only the Maths jobs" do
      expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 1, to: 2, total: 2, type: "results"))
    end

    context "when sorting the jobs by most recently published" do
      it "displays the Maths jobs that were published most recently first" do
        expect("Maths 1").to appear_before("Maths Teacher 2")
      end
    end

    context "when clearing all applied filters" do
      before { click_on I18n.t("shared.filter_group.clear_all_filters") }

      it "displays no remove filter links" do
        expect(page).to_not have_css("a", text: "Remove this filter Teacher")
      end
    end

    context "when removing a filter" do
      before { click_on "Remove this filter Teacher" }

      it "removes the filter" do
        expect(page).to_not have_css("a", text: "Remove this filter Teacher")
      end
    end
  end
end

RSpec.describe "Jobseekers can search for jobs on the jobs index page" do
  let(:academy1) { create(:school, school_type: "Academies") }
  let(:academy2) { create(:school, school_type: "Academy") }
  let(:free_school1) { create(:school, school_type: "Free schools") }
  let(:free_school2) { create(:school, school_type: "Free school") }
  let(:local_authority_school1) { create(:school, school_type: "Local authority maintained schools") }
  let(:local_authority_school2) { create(:school, school_type: "Local authority maintained schools") }
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, :teacher, publish_on: Date.current - 1, job_title: "Maths 1", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary]) }
  let!(:maths_job2) { create(:vacancy, :past_publish, :teacher, publish_on: Date.current - 2, job_title: "Maths Teacher 2", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary]) }
  let!(:job1) { create(:vacancy, :past_publish, :teacher, job_title: "Physics Teacher", subjects: ["Physics"], organisations: [academy1], phases: %w[secondary]) }
  let!(:job2) { create(:vacancy, :past_publish, :teacher, job_title: "PE Teacher", subjects: [], organisations: [academy2]) }
  let!(:job3) { create(:vacancy, :past_publish, :teacher, job_title: "Chemistry Teacher", subjects: [], organisations: [free_school1]) }
  let!(:job4) { create(:vacancy, :past_publish, :teacher, job_title: "Geography Teacher", subjects: [], publisher_organisation: free_school1, organisations: [free_school1, free_school2]) }
  let!(:expired_job) { create(:vacancy, :expired, :teacher, job_title: "Maths Teacher", subjects: [], organisations: [school]) }
  let(:per_page) { 2 }

  context "when searching using the mobile search fields" do
    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: per_page))
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "when searching using the desktop search field" do
    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: per_page))
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "jobseekers can use the organisation type filter to search for jobs" do
    let!(:job5) { create(:vacancy, :past_publish, :teacher, job_title: "History Teacher", subjects: [], publisher_organisation: local_authority_school1, organisations: [local_authority_school1, local_authority_school2]) }

    context "when academy is selected" do
      it "only shows vacancies from academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job2, job3, job4])
        expect_page_not_to_show_jobs([maths_job1, maths_job2, job5])
      end
    end

    context "when local authority is selected" do
      it "only shows vacancies from local authorities" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job5])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
      end
    end

    context "when both local authority and academy are selected" do
      it "shows vacancies from both local authorities and academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job2, job3, job4, job5])
        expect_page_not_to_show_jobs([maths_job1, maths_job2])
      end
    end

    context "when used in conjunction with a search term" do
      # testing this unusual edge case around removing auto-populated search terms because it was raising exceptions for us in the past.
      it "returns the correct vacancies even after removing auto-populated search terms" do
        visit jobs_path
        fill_in "Keyword", with: "Physics teacher"
        check "Academy"

        click_on I18n.t("buttons.search")

        click_link "Remove this filter Teacher"
        click_link "Remove this filter Head of year, department, curriculum or phase"
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1])
        expect_page_not_to_show_jobs([job2, job3, job4, job5, maths_job1, maths_job2])
      end
    end
  end

  def expect_page_to_show_jobs(jobs)
    jobs.each do |job|
      expect(page).to have_link(job.job_title, count: 1)
    end
  end

  def expect_page_not_to_show_jobs(jobs)
    jobs.each do |job|
      expect(page).not_to have_link job.job_title
    end
  end
end
