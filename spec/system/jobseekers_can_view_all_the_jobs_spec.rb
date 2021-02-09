require "rails_helper"

RSpec.describe "Jobseekers can view all the jobs" do
  let(:home_page) { PageObjects::Home.new }
  let(:jobs_page) { PageObjects::Vacancy::Index.new }

  let!(:school) { create(:school) }
  let!(:published_jobs) do
    create_list(
      :vacancy, 5, :past_publish,
      expires_at: 2.years.from_now,
      organisation_vacancies_attributes: [{ organisation: school }]
    )
  end
  let!(:draft_jobs) { create_list(:vacancy, 2, :draft) }

  it "jobseekers can visit the home page, perform an empty search and view jobs" do
    home_page.load

    home_page.search

    expect(jobs_page).to be_displayed
  end

  describe "pagination" do
    before do
      stub_const("Search::SearchBuilder::DEFAULT_HITS_PER_PAGE", 2)
    end

    context "when visiting the home page and performing an empty search" do
      before do
        home_page.load
        home_page.search
      end

      it "jobseekers can view jobs and navigate between pages" do
        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content("Showing 1 to 2 of 5 results")

        jobs_page.pagination.go_to("Next")

        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content("Showing 3 to 4 of 5 results")

        jobs_page.pagination.go_to("Previous")

        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content("Showing 1 to 2 of 5 results")

        jobs_page.pagination.go_to("3")

        expect(jobs_page).to have_jobs(count: 1)
        expect(jobs_page.stats).to have_content("Showing 5 to 5 of 5 results")
      end
    end

    context "when visiting the jobs page" do
      before { jobs_page.load }

      it "jobseekers can view jobs and navigate between pages" do
        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content("Showing 1 to 2 of 5 results")

        jobs_page.pagination.go_to("Next")

        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content("Showing 3 to 4 of 5 results")

        jobs_page.pagination.go_to("Previous")

        expect(jobs_page).to have_jobs(count: 2)
        expect(jobs_page.stats).to have_content("Showing 1 to 2 of 5 results")

        jobs_page.pagination.go_to("3")

        expect(jobs_page).to have_jobs(count: 1)
        expect(jobs_page.stats).to have_content("Showing 5 to 5 of 5 results")
      end
    end
  end

  describe "sorting" do
    let!(:newest_job) do
      create(
        :vacancy, :past_publish, publish_on: Date.current, expires_at: 1.year.from_now,
                                 organisation_vacancies_attributes: [{ organisation: school }]
      )
    end
    let!(:expires_tomorrow_job) do
      create(:vacancy, :past_publish, :expire_tomorrow, organisation_vacancies_attributes: [{ organisation: school }])
    end

    context "when visiting the home page and performing an empty search" do
      before do
        home_page.load
        home_page.search
      end

      it "jobseekers can view jobs and sort jobs", js: true do
        expect(jobs_page).to have_jobs(count: 7)
        expect(jobs_page.sort_field.value).to eq("publish_on_desc")
        expect(jobs_page.jobs.first.job_title).to eq(newest_job.job_title)

        jobs_page.sort_field.find("option[value='expires_at_asc']").click

        expect(jobs_page.sort_field.value).to eq("expires_at_asc")
        expect(jobs_page.jobs.first.job_title).to eq(expires_tomorrow_job.job_title)
      end
    end

    context "when visiting the jobs page" do
      before { jobs_page.load }

      it "jobseekers can view jobs and sort jobs", js: true do
        expect(jobs_page).to have_jobs(count: 7)
        expect(jobs_page.sort_field.value).to eq("publish_on_desc")
        expect(jobs_page.jobs.first.job_title).to eq(newest_job.job_title)

        jobs_page.sort_field.find("option[value='expires_at_asc']").click

        expect(jobs_page.sort_field.value).to eq("expires_at_asc")
        expect(jobs_page.jobs.first.job_title).to eq(expires_tomorrow_job.job_title)
      end
    end
  end
end
