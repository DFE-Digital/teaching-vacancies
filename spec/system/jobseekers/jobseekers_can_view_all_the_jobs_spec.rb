require "rails_helper"

RSpec.describe "Jobseekers can view all the jobs" do
  let!(:school) { create(:school) }
  let!(:published_jobs) { create_list(:vacancy, 5, :past_publish, expires_at: 2.years.from_now, organisations: [school]) }
  let!(:draft_jobs) { create_list(:vacancy, 2, :draft) }

  it "jobseekers can visit the home page, perform an empty search and view jobs" do
    visit root_path
    click_on I18n.t("buttons.search")

    expect(page).to have_current_path(jobs_path, ignore_query: true)
  end

  it "jobseekers can visit the home page and use secondary navigation to view jobs" do
    visit root_path

    within ".sub-navigation" do
      click_on I18n.t("sub_nav.jobs")
      expect(page).to have_current_path(jobs_path, ignore_query: true)
    end
  end

  it "jobseekers can visit the home page and use secondary navigation to view schools" do
    visit root_path

    within ".sub-navigation" do
      click_on I18n.t("sub_nav.schools")
      expect(page).to have_current_path(organisations_path, ignore_query: true)
    end
  end

  it "jobseekers can distinguish between the listed jobs that allow to apply through Teaching Vacancies and the ones who don't" do
    job_without_apply = create(:vacancy, :no_tv_applications, :past_publish, expires_at: 2.years.from_now, organisations: [school])
    visit jobs_path

    published_jobs.each do |job|
      expect(page.find("h2 span", text: job.job_title))
        .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end
    expect(page.find("h2 span", text: job_without_apply.job_title))
      .to have_no_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
  end

  describe "pagination" do
    shared_examples "jobseekers can view jobs and navigate between pages" do
      it "jobseekers can view jobs and navigate between pages" do
        expect(page).to have_css(".search-results > .search-results__item", count: 2)
        expect(page).to have_content "Showing 1 to 2 of 5 results"

        within ".govuk-pagination" do
          click_on "Next"
        end

        expect(page).to have_css(".search-results > .search-results__item", count: 2)
        expect(page).to have_content "Showing 3 to 4 of 5 results"

        within ".govuk-pagination" do
          click_on "Previous"
        end

        expect(page).to have_css(".search-results > .search-results__item", count: 2)
        expect(page).to have_content "Showing 1 to 2 of 5 results"

        within ".govuk-pagination" do
          click_on "3"
        end

        expect(page).to have_css(".search-results > .search-results__item", count: 1)
        expect(page).to have_content "Showing 5 to 5 of 5 results"
      end
    end

    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: 2))
    end

    context "when visiting the home page and performing an empty search" do
      before do
        visit root_path
        click_on I18n.t("buttons.search")
      end

      it_behaves_like "jobseekers can view jobs and navigate between pages"
    end

    context "when visiting the jobs page" do
      before { visit jobs_path }

      it_behaves_like "jobseekers can view jobs and navigate between pages"
    end
  end
end
