require "rails_helper"

RSpec.xdescribe "organisations/index" do
  let(:search_criteria) { {} }

  before do
    assign :search_form, SchoolSearchForm.new(search_criteria)
    assign :school_search, Search::SchoolSearch.new(search_criteria)
    assign :pagy, Pagy.new(count: 0)
    assign :schools, []
    render
  end

  it_behaves_like "a rendered mobile search filter component",
                  { education_phase: %w[primary] },
                  I18n.t("jobs.education_phase_options.primary")
end
