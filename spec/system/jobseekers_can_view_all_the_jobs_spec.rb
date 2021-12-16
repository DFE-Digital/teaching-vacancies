require "rails_helper"

RSpec.describe "Jobseekers can view all the jobs" do
  let!(:school) { create(:school) }
  let!(:published_jobs) { create_list(:vacancy, 5, :past_publish, expires_at: 2.years.from_now, organisations: [school]) }
  let!(:draft_jobs) { create_list(:vacancy, 2, :draft) }

  it "jobseekers can visit the home page, perform an empty search and view jobs" do
    visit root_path
    click_on I18n.t("buttons.search")

    expect(current_path).to eq(jobs_path)
  end

  describe "pagination" do
    before do
      stub_const("Search::VacancySearch::DEFAULT_HITS_PER_PAGE", 2)
    end

    context "when visiting the home page and performing an empty search" do
      before do
        visit root_path
        click_on I18n.t("buttons.search")
      end

      it "jobseekers can view jobs and navigate between pages" do
        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 1 to 2 of 5 results")

        within "ul.pagination" do
          click_on "Next"
        end

        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 3 to 4 of 5 results")

        within "ul.pagination" do
          click_on "Previous"
        end

        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 1 to 2 of 5 results")

        within "ul.pagination" do
          click_on "3"
        end

        expect(page).to have_css("li.vacancy", count: 1)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 5 to 5 of 5 results")
      end
    end

    context "when visiting the jobs page" do
      before { visit jobs_path }

      it "jobseekers can view jobs and navigate between pages" do
        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 1 to 2 of 5 results")

        within "ul.pagination" do
          click_on "Next"
        end

        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 3 to 4 of 5 results")

        within "ul.pagination" do
          click_on "Previous"
        end

        expect(page).to have_css("li.vacancy", count: 2)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 1 to 2 of 5 results")

        within "ul.pagination" do
          click_on "3"
        end

        expect(page).to have_css("li.vacancy", count: 1)
        expect(page).to have_css(".search-results__header-stats", text: "Showing 5 to 5 of 5 results")
      end
    end
  end

  describe "sorting" do
    let!(:newest_job) { create(:vacancy, :past_publish, publish_on: Date.current, expires_at: 1.year.from_now, organisations: [school]) }
    let!(:expires_tomorrow_job) { create(:vacancy, :past_publish, :expires_tomorrow, organisations: [school]) }

    context "when visiting the home page and performing an empty search" do
      before do
        visit root_path
        click_on I18n.t("buttons.search")
      end

      it "jobseekers can view jobs and sort jobs", js: true do
        expect(page.find("#jobs-sort-field").value).to eq("publish_on_desc")

        expect(page).to have_css("li.vacancy", count: 7) do |jobs|
          expect(jobs[0]).to have_content(newest_job.job_title)
        end

        page.find("#jobs-sort-field > option[value='expires_at_asc']").click

        expect(page.find("#jobs-sort-field").value).to eq("expires_at_asc")

        expect(page).to have_css("li.vacancy", count: 7) do |jobs|
          expect(jobs[0]).to have_content(expires_tomorrow_job.job_title)
        end
      end
    end

    context "when visiting the jobs page" do
      before { visit jobs_path }

      it "jobseekers can view jobs and sort jobs", js: true do
        expect(page.find("#jobs-sort-field").value).to eq("publish_on_desc")

        expect(page).to have_css("li.vacancy", count: 7) do |jobs|
          expect(jobs[0]).to have_content(newest_job.job_title)
        end

        page.find("#jobs-sort-field > option[value='expires_at_asc']").click

        expect(page.find("#jobs-sort-field").value).to eq("expires_at_asc")

        expect(page).to have_css("li.vacancy", count: 7) do |jobs|
          expect(jobs[0]).to have_content(expires_tomorrow_job.job_title)
        end
      end
    end
  end
end
