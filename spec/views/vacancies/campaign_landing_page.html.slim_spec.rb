require "rails_helper"

RSpec.describe "vacancies/campaign_landing_page" do
  subject(:campaign_landing_view) { Capybara.string(rendered) }

  let(:school) { build_stubbed(:school, geopoint: "POINT(-0.019501 51.504949)") }
  let(:school2) { build_stubbed(:school, geopoint: "POINT(-1.8964 52.4820)") }

  let(:recent_part_time_maths_job) do
    build_stubbed(
      :vacancy,
      :secondary,
      :past_publish,
      :no_tv_applications,
      job_roles: %w[teacher],
      working_patterns: %w[part_time],
      publish_on: Date.current - 1,
      job_title: "Maths Teacher",
      subjects: %w[Mathematics],
      organisations: [school],
      expires_at: Date.current + 1,
    )
  end

  let(:older_part_time_maths_job) do
    build_stubbed(
      :vacancy,
      :past_publish,
      :secondary,
      :no_tv_applications,
      job_roles: %w[teacher],
      working_patterns: %w[part_time],
      publish_on: Date.current - 2,
      job_title: "Maths Teacher",
      subjects: %w[Mathematics],
      organisations: [school2],
      expires_at: Date.current + 3,
    )
  end
  let(:vacancies) { [recent_part_time_maths_job, older_part_time_maths_job] }
  let(:campaign_page) { CampaignPage["FAKE1+CAMPAIGN"] }
  let(:campaign_params) { CampaignSearchParamsMerger.new({}, campaign_page).merged_params }
  let(:form) { Jobseekers::SearchForm.new(campaign_params.merge(landing_page: campaign_page)) }
  let(:vacancies_search) { Search::VacancySearch.new(form.to_hash, sort: form.sort) }
  let(:pagy) { Pagy.new({ count: 2, page: 1 }) }

  before do
    allow(vacancies_search).to receive(:vacancies) { vacancies }
    assign :campaign_page, campaign_page
    assign :form, form
    assign :jobseeker_name, "John"
    assign :subject, "Mathematics"
    assign :vacancies_search, vacancies_search
    assign :vacancies, vacancies
    assign :pagy, pagy

    render
  end

  it "contains the expected content and vacancies with personalized jobseeker name" do
    expect(campaign_landing_view).to have_css("h1", text: "John, find the right mathematics fake job for you")

    expect(campaign_landing_view).to have_css("#search-results")
    within "#search-results" do
      expect(campaign_landing_view).to have_link(recent_part_time_maths_job.job_title, href: job_path(recent_part_time_maths_job))
      expect(campaign_landing_view).to have_link(older_part_time_maths_job.job_title, href: job_path(older_part_time_maths_job))
    end
    expect(campaign_landing_view).to have_css(".sort-container")
    expect(campaign_landing_view).to have_select("Sort by", selected: "Newest job")
  end
end
