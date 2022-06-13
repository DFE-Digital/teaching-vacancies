require "rails_helper"

RSpec.describe SearchResultsHeadingComponent, type: :component do
  subject { render_inline(described_class.new(vacancies_search: vacancies_search, landing_page: landing_page)) }

  let(:vacancies_search) { instance_double(Search::VacancySearch) }
  let(:landing_page) { nil }
  let(:keyword) { "maths" }
  let(:location) { "London" }
  let(:count) { 10 }
  let(:transportation_type) { "public_transport" }
  let(:travel_time) { "45" }

  before do
    allow(vacancies_search).to receive(:keyword).and_return(keyword)
    allow(vacancies_search).to receive_message_chain(:location_search, :location).and_return(location)
    allow(vacancies_search).to receive_message_chain(:total_count).and_return(count)
    allow(vacancies_search).to receive(:transportation_type).and_return(transportation_type)
    allow(vacancies_search).to receive(:travel_time).and_return(travel_time)
    allow(vacancies_search).to receive(:organisation_slug).and_return(nil)
  end

  context "when landing_page is given" do
    let(:landing_page) { instance_double(LandingPage, heading: "10 sorcery jobs") }

    it "renders correct heading" do
      expect(subject.text).to eq("10 sorcery jobs")
    end
  end

  context "when searching with a keyword and a location without commute time" do
    let(:transportation_type) { "" }
    let(:travel_time) { "" }

    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs match ‘#{keyword}’ in ‘#{location}’")
    end
  end

  context "when searching with a keyword and a location with commute time" do
    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs match ‘#{keyword}’ within #{travel_time} minutes by #{transportation_type.humanize.downcase} from ‘#{location}’")
    end
  end

  context "when searching with a keyword and no location" do
    let(:location) { nil }

    it "renders correct heading text" do
      expect(subject.text).to eq("#{count} jobs match ‘#{keyword}’")
    end
  end

  context "when neither keyword, location, or organisation slug are present" do
    let(:keyword) { nil }
    let(:location) { nil }
    before { subject }

    it "renders correct heading" do
      expect(page).to have_content(
        I18n.t("jobs.search_result_heading.without_search", jobs_count: count, count: count),
      )
    end
  end

  context "when organisation slug is present" do
    before do
      allow(vacancies_search).to receive(:organisation_slug).and_return("bexleyheath-academy")
      allow(vacancies_search).to receive_message_chain(:organisation, :name).and_return("Bexleyheath Academy")
      subject
    end

    it "renders correct heading" do
      expect(page).to have_content(vacancies_search.organisation.name)
    end
  end
end
