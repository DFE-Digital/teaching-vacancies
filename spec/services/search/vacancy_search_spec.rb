require "rails_helper"

RSpec.describe Search::VacancySearch do
  subject { described_class.new(form_hash, sort_by: jobs_sort, page: page, per_page: per_page, fuzzy: fuzzy) }

  let(:form_hash) do
    {
      keyword: keyword,
      location: location,
      radius: radius,
    }.compact
  end

  let(:keyword) { "maths teacher" }
  let(:location) { "" }
  let(:radius) { 10 }
  let(:jobs_sort) { Search::VacancySearchSort::RELEVANCE }
  let(:per_page) { nil }
  let(:page) { 1 }
  let(:fuzzy) { true }
  let(:filter_query) { Search::FiltersBuilder.new(form_hash).filter_query }
  let!(:location_polygon) { create(:location_polygon, name: "london") }
  let(:buffered_polygon) { LocationPolygon.buffered(radius).find(location_polygon.id) }

  describe "pagination helpers" do
    let(:per_page) { 20 }
    let(:page) { 3 }

    before do
      mock_algolia_search(double(none?: false), 50, keyword, anything)
    end

    it "returns the expected bounds" do
      expect(subject).not_to be_out_of_bounds

      expect(subject.page_from).to eq(41)
      expect(subject.page_to).to eq(50)
    end

    context "when out of bounds" do
      before do
        mock_algolia_search(double(none?: false), 20, keyword, anything)
      end

      it "returns the expected bounds" do
        expect(subject).to be_out_of_bounds

        expect(subject.page_from).to eq(41)
        expect(subject.page_to).to eq(20)
      end
    end
  end

  describe "building location search" do
    let(:location) { location_polygon.name }

    context "when a polygon search is carried out" do
      before { allow_any_instance_of(Search::LocationBuilder).to receive(:search_with_polygons?).and_return(true) }

      it "sets location in the active params hash to the polygon's name" do
        expect(subject.active_criteria[:location]).to eq("london")
      end
    end
  end

  describe "building filters" do
    it "calls the filters builder" do
      expect(Search::FiltersBuilder).to receive(:new).with(form_hash).and_call_original
      subject.search_filters
    end
  end

  describe "performing search" do
    describe "fuzziness" do
      before do
        mock_algolia_search(double(raw_answer: nil), 50, keyword, anything)
      end

      context "when enabled" do
        let(:fuzzy) { true }

        it "sets Algolia typo tolerance to true" do
          expect(Search::Strategies::Algolia).to receive(:new).with(hash_including(typo_tolerance: true)).and_call_original
          subject.vacancies
        end
      end

      context "when disabled" do
        let(:fuzzy) { false }

        it "sets Algolia typo tolerance to false" do
          expect(Search::Strategies::Algolia).to receive(:new).with(hash_including(typo_tolerance: false)).and_call_original
          subject.vacancies
        end
      end
    end

    context "when there is any search criteria" do
      context "when location matches a location polygon" do
        let(:location) { location_polygon.name }
        let(:search_params) do
          {
            keyword: keyword,
            polygons: buffered_polygon.to_algolia_polygons,
            filters: filter_query,
            per_page: 20,
            page: page,
            typo_tolerance: true,
          }
        end

        it "calls algolia search with the correct parameters" do
          expect(Search::Strategies::Algolia).to receive(:new).with(search_params).and_call_original
          subject.vacancies
        end
      end

      context "when location does not match a location polygon" do
        let(:location) { "SW1A 1AA" }
        let(:radius) { 10 }
        let(:search_params) do
          {
            keyword: keyword,
            coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: convert_miles_to_metres(radius),
            filters: filter_query,
            per_page: 20,
            page: page,
            typo_tolerance: true,
          }
        end

        it "calls algolia search with the correct parameters" do
          expect(Search::Strategies::Algolia).to receive(:new).with(search_params).and_call_original
          subject.vacancies
        end
      end
    end

    context "when there is not any search criteria" do
      let(:keyword) { "" }
      let(:jobs_sort) { Search::VacancySearchSort::PUBLISH_ON_DESC }

      it "calls `Search::Strategies::Database` with the correct parameters" do
        expect(Search::Strategies::Database).to receive(:new).with(1, 20, an_instance_of(Search::VacancySearchSort)).and_call_original
        subject.vacancies
      end
    end
  end

  describe "wider suggestions" do
    context "when location matches a location polygon" do
      let(:location) { location_polygon.name }

      context "when vacancies is not empty" do
        let(:vacancies) { double("vacancies") }

        let(:arguments_to_algolia) do
          {
            insidePolygon: buffered_polygon.to_algolia_polygons,
            filters: filter_query,
            hitsPerPage: 20,
            page: page,
            typoTolerance: true,
          }
        end

        before do
          allow(vacancies).to receive(:empty?).and_return(false)
          mock_algolia_search(vacancies, 1, keyword, arguments_to_algolia)
          freeze_time
        end

        it "does not call the wider suggestions builder" do
          expect(Search::WiderSuggestionsBuilder).not_to receive(:new)
          subject.wider_search_suggestions
        end
      end

      context "when vacancies is empty" do
        let(:search_params) do
          {
            keyword: keyword,
            polygons: buffered_polygon.to_algolia_polygons,
            filters: filter_query,
            per_page: 20,
            page: page,
            typo_tolerance: true,
          }
        end

        before { freeze_time }

        it "calls the wider suggestions builder" do
          expect(Search::WiderSuggestionsBuilder).to receive(:new).and_call_original
          subject.wider_search_suggestions
        end
      end
    end

    context "when location does not match a location polygon" do
      let(:location) { "SW1A 1AA" }
      let(:radius) { 10 }
      let(:search_params) do
        {
          keyword: keyword,
          coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
          radius: convert_miles_to_metres(radius),
          filters: filter_query,
          per_page: 20,
          page: page,
          typo_tolerance: true,
        }
      end

      context "when vacancies is not empty" do
        let(:vacancies) { double("vacancies") }

        let(:arguments_to_algolia) do
          {
            aroundLatLng: Geocoder::DEFAULT_STUB_COORDINATES,
            aroundRadius: convert_miles_to_metres(radius),
            filters: filter_query,
            hitsPerPage: 20,
            page: page,
            typoTolerance: true,
          }
        end

        before do
          allow(vacancies).to receive(:empty?).and_return(false)
          mock_algolia_search(vacancies, 1, keyword, arguments_to_algolia)
        end

        it "does not call the wider suggestions builder" do
          expect(Search::WiderSuggestionsBuilder).not_to receive(:new)
          subject.wider_search_suggestions
        end
      end

      context "when vacancies is empty" do
        it "calls the wider suggestions builder" do
          expect(Search::WiderSuggestionsBuilder).to receive(:new).and_call_original
          subject.wider_search_suggestions
        end
      end
    end
  end
end
