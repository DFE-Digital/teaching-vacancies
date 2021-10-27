require "rails_helper"

RSpec.describe Jobseekers::SearchResults::HeadingComponent, type: :component do
  subject { render_inline(described_class.new(vacancies_search: vacancies_search, landing_page: landing_page)) }

  let(:vacancies_search) { instance_double(Search::VacancySearch) }
  let(:landing_page) { nil }
  let(:keyword) { "maths" }
  let(:location) { "London" }
  let(:count) { 10 }
  let(:radius) { 10 }

  before do
    allow(vacancies_search).to receive(:keyword).and_return(keyword)
    allow(vacancies_search).to receive_message_chain(:location_search, :location).and_return(location)
    allow(vacancies_search).to receive_message_chain(:total_count).and_return(count)
    allow(vacancies_search).to receive_message_chain(:location_search, :radius).and_return(radius)
  end

  context "when landing_page is a job role" do
    let(:landing_page) { "teaching-assistant" }

    it "renders correct heading" do
      expect(subject.text).to eq("10 teaching assistant jobs")
    end
  end

  context "when searching with a keyword and a location with no radius (a polygon search)" do
    let(:radius) { 0 }

    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs match ‘#{keyword}’ in ‘#{location}’")
    end
  end

  context "when searching with a keyword and a location with a radius (polygon or point)" do
    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs match ‘#{keyword}’ within #{radius} miles of ‘#{location}’")
    end
  end

  context "when searching with a keyword and no location" do
    let(:location) { nil }

    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs match ‘#{keyword}’")
    end
  end

  context "when searching with a location and no keyword" do
    let(:keyword) { nil }

    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs found within #{radius} miles of ‘#{location}’")
    end
  end

  context "when neither keyword and location are present" do
    let(:keyword) { nil }
    let(:location) { nil }
    before { subject }

    it "renders correct heading" do
      expect(rendered_component).to include(
        I18n.t("jobs.search_result_heading.without_search_html", jobs_count: count, count: count),
      )
    end
  end
end
