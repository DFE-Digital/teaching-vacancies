require "rails_helper"

RSpec.describe "Jobseekers can search for jobs" do
  let(:jobs_page) { PageObjects::Vacancy::Index.new }
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, id: "67991ea9-431d-4d9d-9c99-a78b80108fe1", job_title: "Maths Teacher", organisation_vacancies_attributes: [{ organisation: school }]) }
  let!(:maths_job2) { create(:vacancy, :past_publish, id: "7bfadb84-cf30-4121-88bd-a9f958440cc9", job_title: "Maths Teacher 2", organisation_vacancies_attributes: [{ organisation: school }]) }
  let!(:job1) { create(:vacancy, :past_publish, id: "20cc99ff-4fdb-4637-851a-68cf5f8fea9f", job_title: "Physics Teacher", organisation_vacancies_attributes: [{ organisation: school }]) }
  let!(:job2) { create(:vacancy, :past_publish, id: "9910d184-5686-4ffc-9322-69aa150c19d3", job_title: "PE Teacher", organisation_vacancies_attributes: [{ organisation: school }]) }
  let!(:job3) { create(:vacancy, :past_publish, id: "3bf67da6-039c-4ee1-bf59-8475672a0d2b", job_title: "Chemistry Teacher", organisation_vacancies_attributes: [{ organisation: school }]) }
  let!(:job4) { create(:vacancy, :past_publish, id: "e750baf6-cc9a-4b93-84cf-ee4e5f8a7ee4", job_title: "Geography Teacher", organisation_vacancies_attributes: [{ organisation: school }]) }
  let!(:expired_job) { create(:vacancy, :expired, id: "0f86d38c-56d4-48d3-b8a2-474f19d4908e", job_title: "Maths Teacher", organisation_vacancies_attributes: [{ organisation: school }]) }

  before do
    stub_const("Search::VacancySearch::DEFAULT_HITS_PER_PAGE", 2)

    jobs_page.load
    jobs_page.filters.keyword.set(keyword)
    jobs_page.search
  end

  context "when searching for teacher jobs" do
    let(:keyword) { "Teacher" }

    it "displays page 1 jobs", vcr: { cassette_name: "algoliasearch teacher page 1" } do
      expect(jobs_page).to have_jobs(count: 2)
      expect(jobs_page.stats).to have_content(strip_tags(I18n.t("jobs.number_of_results_html", first: 1, last: 2, count: 6)))
    end

    context "when navigating between pages" do
      it "displays page 3 jobs", vcr: { cassette_name: "algoliasearch teacher page 3" } do
        jobs_page.pagination.go_to("3")

        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content(strip_tags(I18n.t("jobs.number_of_results_html", first: 5, last: 6, count: 6)))
      end
    end
  end

  context "when searching for maths jobs", vcr: { cassette_name: "algoliasearch maths" } do
    let(:keyword) { "Maths Teacher" }

    it "displays the Maths jobs" do
      expect(jobs_page).to have_jobs(count: 2)
      expect(jobs_page.stats).to have_content(strip_tags(I18n.t("jobs.number_of_results_one_page_html", count: 2)))
      expect(jobs_page.jobs.first.job_title).to eq("Maths Teacher")
      expect(jobs_page.jobs.last.job_title).to eq("Maths Teacher 2")
    end

    context "when sorting the jobs", js: true do
      before do
        jobs_page.sort_field.find("option[value='expires_at_asc']").click
      end

      it "displays the Maths jobs that expires soonest first" do
        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content(strip_tags(I18n.t("jobs.number_of_results_one_page_html", count: 2)))
        expect(jobs_page.jobs.first.job_title).to eq("Maths Teacher 2")
        expect(jobs_page.jobs.last.job_title).to eq("Maths Teacher")
      end
    end
  end
end
