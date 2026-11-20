require "rails_helper"

RSpec.describe "organisations/index" do
  include Pagy::Backend

  let(:search_criteria) { {} }

  before do
    assign :search_form, SchoolSearchForm.new(search_criteria)
    assign :school_search, Search::SchoolSearch.new(search_criteria, scope: Organisation.all)
    assign :pagy, pagy_array(schools).first
    assign :schools, schools
    render
  end

  context "with no results" do
    let(:schools) { [] }

    it_behaves_like "a rendered mobile search filter component",
                    { education_phase: %w[primary] },
                    I18n.t("jobs.education_phase_options.primary")
  end

  context "when the school has an image" do
    let(:school_name) { Faker::Educator.primary_school }
    let(:schools) { create_list(:school, 1, :with_image, name: school_name) }

    it "renders the school" do
      expect(rendered).to have_content(school_name)
    end
  end
end
