require "rails_helper"

RSpec.describe "vacancies/index" do
  include Pagy::Backend

  subject(:index_view) { Capybara.string(rendered) }

  let(:form) { Jobseekers::SearchForm.new(search_criteria) }
  let(:vacancies_search) { Search::VacancySearch.new(form.to_hash, sort:) }
  let(:school) { build_stubbed(:school) }
  let(:vacancy) { build_stubbed(:vacancy, :secondary, job_title: "Head of Hogwarts", subjects: %w[Potions], working_patterns: %w[part_time], organisations: [school]) }
  let(:vacancies) { [vacancy] }
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

  context "with a landing page" do
    let(:landing_page) { LandingPage["part-time-potions-and-sorcery-teacher-jobs"] }
    let(:search_criteria) { {} }

    describe "mobile filters" do
      it_behaves_like "a rendered mobile search filter component",
                      { visa_sponsorship_availability: %w[true] },
                      I18n.t("jobs.filters.visa_sponsorship_availability.option")
    end

    describe "landing pages" do
      it "contains the expected content and vacancies" do
        expect(rendered).to have_css("h1", text: "Jobs (1)")
        expect(rendered).to have_link("Head of Hogwarts")
        expect(rendered).to have_link(vacancy.job_title.to_s)
        expect(rendered).to have_css("p", text: school.name)
      end
    end
  end

  context "with a multi-keyword location landing page" do
    let(:search_criteria) { landing_page.criteria }
    let(:landing_page) { KeywordLocationLandingPage.new("early-years-teacher", "coventry") }

    it "converts the keywords back to their original" do
      pending("test")
      expect(rendered).to have_content("early years teacher")
    end

    it "converts the location back to its original" do
      expect(rendered).to have_content("Coventry")
    end
  end
end
