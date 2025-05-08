require "rails_helper"

RSpec.describe "vacancies/index" do
  let(:search_criteria) { {} }

  before do
    assign :form, Jobseekers::SearchForm.new(search_criteria)
    assign :vacancies_search, Search::VacancySearch.new(search_criteria)
    render
  end

  it_behaves_like "a rendered mobile search filter component",
                  { visa_sponsorship_availability: %w[true] },
                  I18n.t("jobs.filters.visa_sponsorship_availability.option")
end
