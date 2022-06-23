require "rails_helper"

RSpec.shared_examples "a successful search" do
  context "when searching for teacher jobs" do
    let(:keyword) { "Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("button", text: "Remove this filterTeacher")
    end

    it "displays page 1 jobs" do
      within("ul.search-results") { expect(page).to have_css("li", count: 2) }
      expect(page).to have_css(".search-results-sorting__stats", text: strip_tags(I18n.t("jobs.number_of_results_html", first: 1, last: 2, count: 6)))
    end

    context "when navigating between pages" do
      it "displays page 3 jobs" do
        within "ul.pagination" do
          click_on "3"
        end

        within("ul.search-results") { expect(page).to have_css("li", count: 2) }
        expect(page).to have_css(".search-results-sorting__stats", text: strip_tags(I18n.t("jobs.number_of_results_html", first: 5, last: 6, count: 6)))
      end
    end
  end

  context "when searching for maths jobs" do
    let(:per_page) { 100 }
    let(:keyword) { "Maths Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("button", text: "Remove this filterMathematics")
      expect(page).to have_css("button", text: "Remove this filterTeacher")
    end

    it "displays only the Maths jobs" do
      expect(page).to have_css(".search-results-sorting__stats", text: strip_tags(I18n.t("jobs.number_of_results_one_page_html", count: 2)))
    end

    context "when sorting the jobs by most recently published" do
      it "displays the Maths jobs that were published most recently first" do
        expect("Maths 1").to appear_before("Maths Teacher 2")
      end
    end

    context "when sorting by most relevant" do
      before { click_on I18n.t("jobs.sort_by.most_relevant").humanize }

      it "lists the most relevant jobs first" do
        expect("Maths Teacher 2").to appear_before("Maths 1")
      end
    end

    context "when clearing all applied filters" do
      before { click_on I18n.t("shared.filter_group.clear_all_filters") }

      it "displays no filter remove buttons" do
        expect(page).to_not have_css("button", text: "Remove this filterMathematics")
        expect(page).to_not have_css("button", text: "Remove this filterTeacher")
      end
    end
  end
end

RSpec.describe "Jobseekers can search for jobs on the jobs index page" do
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, publish_on: Date.current - 1, job_title: "Maths 1", job_roles: %i[teacher], subjects: %w[Mathematics], organisations: [school]) }
  let!(:maths_job2) { create(:vacancy, :past_publish, publish_on: Date.current - 2, job_title: "Maths Teacher 2", job_roles: %i[teacher], subjects: %w[Mathematics], organisations: [school]) }
  let!(:job1) { create(:vacancy, :past_publish, job_title: "Physics Teacher", job_roles: %i[teacher], subjects: [], organisations: [school]) }
  let!(:job2) { create(:vacancy, :past_publish, job_title: "PE Teacher", job_roles: %i[teacher], subjects: [], organisations: [school]) }
  let!(:job3) { create(:vacancy, :past_publish, job_title: "Chemistry Teacher", job_roles: %i[teacher], subjects: [], organisations: [school]) }
  let!(:job4) { create(:vacancy, :past_publish, job_title: "Geography Teacher", job_roles: %i[teacher], subjects: [], organisations: [school]) }
  let!(:expired_job) { create(:vacancy, :expired, job_title: "Maths Teacher", job_roles: %i[teacher], subjects: [], organisations: [school]) }
  let(:per_page) { 2 }

  context "when searching using the mobile search fields" do
    before do
      stub_const("Search::VacancySearch::DEFAULT_HITS_PER_PAGE", per_page)
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "when searching using the desktop search field" do
    before do
      stub_const("Search::VacancySearch::DEFAULT_HITS_PER_PAGE", per_page)
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end
end
