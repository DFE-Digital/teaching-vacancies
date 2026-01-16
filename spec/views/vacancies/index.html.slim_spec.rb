require "rails_helper"

RSpec.describe "vacancies/index" do
  include Pagy::Backend

  subject(:index_view) { Capybara.string(rendered) }

  let(:form) { Jobseekers::SearchForm.new(search_criteria) }
  let(:vacancies_search) { Search::VacancySearch.new(form.to_hash, sort:) }
  let(:landing_page) { LandingPage[landing_page_slug] }
  let(:landing_page_slug) { "part-time-potions-and-sorcery-teacher-jobs" }
  let(:school) { build_stubbed(:school) }
  let(:vacancy) { build_stubbed(:vacancy, :secondary, job_title: "Head of Hogwarts", subjects: %w[Potions], working_patterns: %w[part_time], organisations: [school]) }
  let(:vacancies) { [vacancy] }
  let(:search_criteria) { {} }
  let(:sort) { form.sort }
  let(:pagy) { pagy_array(build_stubbed_list(:vacancy, 2)).first }

  before do
    allow(sort).to receive(:many?).and_return(false)
    allow(vacancies_search).to receive(:vacancies) { vacancies }
    assign :form, form
    assign :vacancies_search, vacancies_search
    assign :landing_page, landing_page
    assign :vacancies, vacancies
    assign :pagy, pagy

    render
  end

  describe "mobile filters" do
    it_behaves_like "a rendered mobile search filter component",
                    { visa_sponsorship_availability: %w[true] },
                    I18n.t("jobs.filters.visa_sponsorship_availability.option")
  end

  describe "landing pages" do
    it "contains the expected content and vacancies" do
      expect(index_view).to have_css("h1", text: "Jobs (1)")
      expect(index_view).to have_link("Head of Hogwarts")
      expect(index_view).to have_link(vacancy.job_title.to_s)
      expect(index_view).to have_css("p", text: school.name)
    end
  end
end
