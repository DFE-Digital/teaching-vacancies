require "rails_helper"

RSpec.shared_examples "a successful search" do
  context "when searching for teacher jobs" do
    let(:keyword) { "Teacher" }

    it "displays page 1 jobs" do
      expect(page).to have_css("li.vacancy", count: 2)
      expect(page).to have_css(".search-results__header-stats", text: strip_tags(I18n.t("jobs.number_of_results_html", first: 1, last: 2, count: 6)))
    end

    context "when navigating between pages" do
      it "displays page 3 jobs" do
        within "ul.pagination" do
          click_on "3"
        end

        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: strip_tags(I18n.t("jobs.number_of_results_html", first: 5, last: 6, count: 6)))
      end
    end
  end

  context "when searching for maths jobs" do
    let(:per_page) { 100 }
    let(:keyword) { "Maths Teacher" }

    it "displays only the Maths jobs" do
      expect(page).to have_css(".search-results__header-stats", text: strip_tags(I18n.t("jobs.number_of_results_one_page_html", count: 2)))
    end

    context "when sorting the jobs by most recently published" do
      it "displays the Maths jobs that were published most recently first" do
        expect("Maths 1").to appear_before("Maths Teacher 2")
      end
    end

    context "when sorting by most relevant" do
      before do
        click_on I18n.t("jobs.sort_by.most_relevant").humanize
      end

      it "lists the most relevant jobs first" do
        expect("Maths Teacher 2").to appear_before("Maths 1")
      end
    end
  end
end

RSpec.describe "Jobseekers can search for jobs on the jobs index page" do
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, publish_on: Date.current - 1, id: "67991ea9-431d-4d9d-9c99-a78b80108fe1", job_title: "Maths 1", subjects: [], organisations: [school]) }
  let!(:maths_job2) { create(:vacancy, :past_publish, publish_on: Date.current - 2, id: "7bfadb84-cf30-4121-88bd-a9f958440cc9", job_title: "Maths Teacher 2", subjects: [], organisations: [school]) }
  let!(:job1) { create(:vacancy, :past_publish, id: "20cc99ff-4fdb-4637-851a-68cf5f8fea9f", job_title: "Physics Teacher", subjects: [], organisations: [school]) }
  let!(:job2) { create(:vacancy, :past_publish, id: "9910d184-5686-4ffc-9322-69aa150c19d3", job_title: "PE Teacher", subjects: [], organisations: [school]) }
  let!(:job3) { create(:vacancy, :past_publish, id: "3bf67da6-039c-4ee1-bf59-8475672a0d2b", job_title: "Chemistry Teacher", subjects: [], organisations: [school]) }
  let!(:job4) { create(:vacancy, :past_publish, id: "e750baf6-cc9a-4b93-84cf-ee4e5f8a7ee4", job_title: "Geography Teacher", subjects: [], organisations: [school]) }
  let!(:expired_job) { create(:vacancy, :expired, id: "0f86d38c-56d4-48d3-b8a2-474f19d4908e", job_title: "Maths Teacher", subjects: [], organisations: [school]) }
  let(:per_page) { 2 }

  context "when searching using the mobile search fields" do
    before do
      stub_const("Search::VacancySearch::DEFAULT_HITS_PER_PAGE", per_page)
      visit jobs_path
      page.find(".search-and-filters-form").fill_in "Keyword", with: keyword
      page.find(".search-and-filters-form").click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "when searching using the desktop search field" do
    before do
      stub_const("Search::VacancySearch::DEFAULT_HITS_PER_PAGE", per_page)
      visit jobs_path
      page.find(".search-and-filters-form").fill_in "Keyword", with: keyword
      page.find(".search-and-filters-form").click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end
end
