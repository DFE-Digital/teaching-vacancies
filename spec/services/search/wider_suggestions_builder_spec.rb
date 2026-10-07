require "rails_helper"

RSpec.describe Search::WiderSuggestionsBuilder do
  subject { described_class.new(initial_search) }

  let(:search_params) do
    {
      radius: radius,
      keyword: "test",
      location: location,
    }
  end
  let(:radius) { 6 }
  let(:initial_search) { Search::VacancySearch.new(search_params) }

  describe ".call" do
    let(:pg_search) { double("search") }
    let(:suggestions) { described_class.call(initial_search) }
    let(:location) { "somewhere" }

    before do
      allow(pg_search).to receive(:total_count).and_return(0, 0, 2, 4, 15, 80, 80)
    end

    context "when initial_search is missing the search_criteria[:location] then suggestion search is not allowed" do
      let(:location) { nil }

      it { expect(suggestions).to be_nil }
    end

    context "when initial_search has some results then suggestion search is not allowed" do
      before { allow(initial_search).to receive(:total_count).and_return(1) }

      it { expect(described_class.call(initial_search)).to be_nil }
    end

    describe "returns suggestions", :geocode, :vcr do
      let(:location) { "Hatfield" }

      before do
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/polygons.yml")).map(&:attributes).each { |s| LocationPolygon.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/liverpool_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/basildon_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        YAML.unsafe_load_file(Rails.root.join("spec/fixtures/st_albans_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
        liverpool_org = School.find_by!(town: "Liverpool")
        basildon_org = School.find_by!(town: "Basildon")
        st_albans_org = School.find_by!(town: "St Albans")

        create_list(:vacancy, 5, :published_slugged, job_title: "test liv", organisations: [liverpool_org])
        create_list(:vacancy, 3, :published_slugged, job_title: "test bas", organisations: [basildon_org])
        create_list(:vacancy, 1, :published_slugged, job_title: "test sta", organisations: [st_albans_org])
      end

      context "when initial_search is a Search::VacancySearch" do
        let(:initial_search) { Search::VacancySearch.new(search_params) }
        let(:expected_suggestions) do
          [
            ["10", 1],
            ["50", 4],
            ["200", 9],
          ]
        end

        it "expects wider vacancy counts" do
          expect(suggestions).to eq(expected_suggestions)
        end
      end

      context "when initial_search is a Search::SchoolSearch" do
        let(:initial_search) { Search::SchoolSearch.new(search_params, scope: Organisation.all) }
        let(:expected_suggestions) do
          [
            ["10", 1],
            ["50", 2],
            ["200", 3],
          ]
        end

        it "expects wider school counts" do
          expect(suggestions).to eq(expected_suggestions)
        end
      end
    end
  end
end
