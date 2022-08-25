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
    shared_examples "jobseekers can view jobs and navigate between pages" do
      scenario "jobseekers can view jobs and navigate between pages" do
        expect(page).to have_css("ul.search-results > li", count: 2)
        expect(page).to have_content "Showing 1 to 2 of 5 results"

        expect(page).not_to have_content(I18n.t("jobs.sort_by.most_relevant").humanize)
        expect(page).not_to have_content(I18n.t("jobs.sort_by.publish_on.descending").humanize)

        within ".govuk-pagination" do
          click_on "Next"
        end

        expect(page).to have_css("ul.search-results > li", count: 2)
        expect(page).to have_content "Showing 3 to 4 of 5 results"

        within ".govuk-pagination" do
          click_on "Previous"
        end

        expect(page).to have_css("ul.search-results > li", count: 2)
        expect(page).to have_content "Showing 1 to 2 of 5 results"

        within ".govuk-pagination" do
          click_on "3"
        end

        expect(page).to have_css("ul.search-results > li", count: 1)
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
