require "rails_helper"

RSpec.describe Jobseekers::SearchResults::HeadingComponent, type: :component do
  subject { described_class.new(vacancies_search: vacancies_search) }

  let(:vacancies_search) { instance_double(Search::VacancySearch) }
  let(:keyword) { "maths" }
  let(:location) { "London" }
  let(:polygon_boundaries) { [[51.0, 51.0]] }
  let(:count) { 10 }
  let(:buffer_radius) { nil }

  before do
    allow(vacancies_search).to receive(:keyword).and_return(keyword)
    allow(vacancies_search).to receive_message_chain(:location_search, :location).and_return(location)
    allow(vacancies_search).to receive_message_chain(:location_search, :polygon_boundaries).and_return(polygon_boundaries)
    allow(vacancies_search).to receive_message_chain(:total_count).and_return(count)
    allow(vacancies_search).to receive_message_chain(:location_search, :buffer_radius).and_return(buffer_radius)
    render_inline(subject)
  end

  context "when keyword and search polygon boundaries are present" do
    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.keyword_location_polygon_html", keyword: keyword, location: location, count: count),
      )
    end

    context "and a buffer radius is applied" do
      let(:buffer_radius) { 5 }

      it "renders correct heading" do
        expect(rendered_component).to include(
          I18n.t("jobs.search_result_heading.keyword_location_html", keyword: keyword, location: location, count: count),
        )
      end
    end
  end

  context "when keyword and location are present" do
    let(:polygon_boundaries) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.keyword_location_html", keyword: keyword, location: location, count: count),
      )
    end
  end

  context "when only keyword is present" do
    let(:location) { nil }
    let(:polygon_boundaries) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.keyword_html", keyword: keyword, count: count),
      )
    end
  end

  context "when search polygon boundaries is present but keyword is not present" do
    let(:keyword) do
      nil
    end

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.location_polygon_html", location: location, count: count),
      )
    end

    context "and a buffer radius is applied" do
      let(:buffer_radius) { 5 }

      it "renders correct heading" do
        expect(rendered_component).to include(
          I18n.t("jobs.search_result_heading.location_html", location: location, count: count),
        )
      end
    end
  end

  context "when only location is present" do
    let(:keyword) do
      nil
    end
    let(:polygon_boundaries) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.location_html", location: location, count: count),
      )
    end
  end

  context "when neither keyword and location are present" do
    let(:keyword) { nil }
    let(:location) { nil }
    let(:polygon_boundaries) { nil }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.without_search_html", count: count),
      )
    end
  end
end
