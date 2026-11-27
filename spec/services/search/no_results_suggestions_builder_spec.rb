require "rails_helper"

RSpec.describe Search::NoResultsSuggestionsBuilder do
  subject(:result) { described_class.call(search) }

  let(:search) { Search::VacancySearch.new(criteria) }
  let(:criteria) { { keyword: "geography", location: "liverpool", radius: "5", working_patterns: %w[full_time] } }

  before do
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/polygons.yml")).map(&:attributes).each { |s| LocationPolygon.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/liverpool_schools.yml")).map(&:attributes).each { |s| School.create!(s) }
    YAML.unsafe_load_file(Rails.root.join("spec/fixtures/basildon_schools.yml")).map(&:attributes).each { |s| School.create!(s) }

    create(:vacancy, :past_publish, job_title: "Geography teacher", working_patterns: %w[part_time],
                                    organisations: [School.find_by!(town: "Liverpool")])
    create_list(:vacancy, 2, :past_publish, job_title: "Geography teacher", working_patterns: %w[full_time],
                                            organisations: [School.find_by!(town: "Basildon")])
  end

  describe ".call" do
    context "when the search has results" do
      let(:criteria) { { keyword: "geography" } }

      it { is_expected.to be_nil }
    end

    context "when the search has no criteria" do
      let(:criteria) { {} }

      it { is_expected.to be_nil }
    end

    context "when the search is for an organisation" do
      let(:criteria) { { organisation_slug: "anything", keyword: "unicorn" } }

      it { is_expected.to be_nil }
    end

    context "when a wider radius and a removed filter would return results" do
      it "widens the location first and then offers to remove the filter, never dropping the location" do
        expect(result.suggestions.map(&:type)).to eq(%i[radius filter])
        expect(result.suggestions).to all(satisfy { |suggestion| suggestion.criteria[:location] == "liverpool" })

        radius, filter = result.suggestions
        expect(radius.criteria).to include(radius: "200", working_patterns: %w[full_time])
        expect(radius.count).to eq(2)
        expect(filter.criteria).to eq(criteria.except(:working_patterns))
        expect(filter.count).to eq(1)
        expect(filter.options).to eq(filter: :working_patterns)
      end

      it "offers no spelling suggestion or browse links" do
        expect(result.spelling).to be_nil
        expect(result.browse).to be_empty
      end

      it "limits the number of suggestions" do
        stub_const("#{described_class}::MAX_SUGGESTIONS", 1)

        expect(result.suggestions.map(&:type)).to eq(%i[radius])
      end
    end

    context "when the filter is not one that may be removed" do
      let(:criteria) { { keyword: "geography", visa_sponsorship_availability: %w[true], quick_apply: %w[true] } }

      it "does not offer to remove it" do
        expect(result.suggestions.map(&:options)).not_to include(include(filter: :visa_sponsorship_availability))
      end
    end

    context "when the keyword has several words and dropping one would return results" do
      let(:criteria) { { keyword: "geography unicorn" } }

      it "offers to remove the word that is blocking the search" do
        suggestion = result.suggestions.sole
        expect(suggestion.type).to eq(:keyword)
        expect(suggestion.criteria).to eq(keyword: "geography")
        expect(suggestion.options).to eq(word: "unicorn")
        expect(suggestion.count).to eq(3)
      end
    end

    context "when the keyword is the only criterion and is misspelt" do
      let(:criteria) { { keyword: "geografy" } }

      it "suggests the corrected keyword and lets the jobseeker browse instead of relaxing" do
        expect(result.spelling).to have_attributes(type: :spelling, criteria: { keyword: "geography" }, count: 3)
        expect(result.suggestions).to be_empty
        expect(result.browse.map(&:type)).to eq(%i[teaching])
        expect(result.browse.first.count).to eq(3)
      end
    end

    context "when the keyword is the only criterion and matches nothing similar" do
      let(:criteria) { { keyword: "xylophone" } }

      it "only offers to browse" do
        expect(result.spelling).to be_nil
        expect(result.browse.map(&:type)).to eq(%i[teaching])
      end
    end

    context "when the corrected keyword would still return nothing" do
      let(:criteria) { { keyword: "geografy", location: "liverpool", radius: "0", working_patterns: %w[full_time] } }

      it "does not suggest the correction" do
        expect(result.spelling).to be_nil
      end
    end

    context "when support jobs exist" do
      let(:criteria) { { keyword: "unicorn" } }

      before { create(:vacancy, :past_publish, job_title: "Cover supervisor", job_roles: %w[it_support]) }

      it "also lets the jobseeker browse support jobs" do
        expect(result.browse.map(&:type)).to eq(%i[teaching support])
      end
    end
  end
end
