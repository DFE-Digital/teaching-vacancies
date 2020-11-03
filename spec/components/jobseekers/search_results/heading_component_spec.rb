require "rails_helper"

RSpec.describe Jobseekers::SearchResults::HeadingComponent, type: :component do
  subject { described_class.new(vacancies_search: vacancies_search) }

  let(:vacancies_search) { instance_double(Search::VacancySearchBuilder) }
  let(:keyword) { "maths" }
  let(:location) { "London" }
  let(:location_polygon) { "London" }
  let(:count) { 10 }

  before do
    allow(vacancies_search).to receive(:keyword).and_return(keyword)
    allow(vacancies_search).to receive_message_chain(:location_search, :location).and_return(location)
    allow(vacancies_search).to receive_message_chain(:location_search, :location_polygon).and_return(location_polygon)
    allow(vacancies_search).to receive_message_chain(:vacancies, :raw_answer, :[]).with("nbHits").and_return(count)
    render_inline(subject)
  end

  context "when keyword and location polygon are present" do
    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.keyword_location_polygon_html", keyword: keyword, location: location, count: count),
      )
    end
  end

  context "when keyword and location are present" do
    let(:location_polygon) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.keyword_location_html", keyword: keyword, location: location, count: count),
      )
    end
  end

  context "when only keyword is present" do
    let(:location) { nil }
    let(:location_polygon) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.keyword_html", keyword: keyword, count: count),
      )
    end
  end

  context "when location polygon is present but keyword is not present" do
    let(:keyword) do
      nil
    end

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.location_polygon_html", location: location, count: count),
      )
    end
  end

  context "when only location is present" do
    let(:keyword) do
      nil
    end
    let(:location_polygon) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.location_html", location: location, count: count),
      )
    end
  end

  context "when neither keyword and location are present" do
    let(:keyword) { nil }
    let(:location) { nil }
    let(:location_polygon) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.without_search_html", count: count),
      )
    end
  end
end
