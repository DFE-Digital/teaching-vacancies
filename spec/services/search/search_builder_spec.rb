require "rails_helper"

RSpec.describe Search::SearchBuilder do
  let(:subject) { described_class.new(form_hash) }

  let(:form_hash) do
    {
      keyword: keyword,
      location: location,
      radius: radius,
      location_category: location_category,
      jobs_sort: jobs_sort,
      per_page: hits_per_page,
      page: page,
    }.compact
  end

  let(:keyword) { "maths teacher" }
  let(:location) { "" }
  let(:radius) { "" }
  let(:location_category) { nil }
  let(:jobs_sort) { "" }
  let(:hits_per_page) { nil }
  let(:page) { 1 }
  let(:filter_query) { Search::FiltersBuilder.new(form_hash).filter_query }
  let!(:location_polygon) { create(:location_polygon, name: "london") }

  describe "#build_location_search" do
    let(:location) { location_polygon.name }

    context "when a location_category_search is carried out" do
      before { allow_any_instance_of(Search::LocationBuilder).to receive(:location_category_search?).and_return(true) }

      it "sets location_category in the active params hash" do
        expect(subject.only_active_to_hash[:location_category]).to eq("london")
      end
    end
  end

  describe "#build_search_filters" do
    it "calls the filters builder" do
      expect(Search::FiltersBuilder).to receive(:new).with(form_hash).and_call_original
      subject
    end
  end

  describe "#build_search_replica" do
    it "calls the replica builder" do
      expect(Search::ReplicaBuilder).to receive(:new).with(form_hash[:jobs_sort], keyword).and_call_original
      subject
    end
  end

  describe "#call_algolia_search" do
    context "when location matches a location polygon" do
      let(:location) { location_polygon.name }
      let(:search_params) do
        {
          keyword: keyword,
          polygons: location_polygon.polygons["polygons"],
          filters: filter_query,
          hits_per_page: 10,
          page: page,
        }
      end

      before { allow(Search::BufferSuggestionsBuilder).to receive_message_chain(:new, :buffer_suggestions) }

      it "calls algolia search with the correct parameters" do
        expect(Search::AlgoliaSearchRequest).to receive(:new).with(search_params).and_call_original
        subject
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
          hits_per_page: 10,
          page: page,
        }
      end

      before { allow(Search::RadiusSuggestionsBuilder).to receive_message_chain(:new, :radius_suggestions) }

      it "calls algolia search with the correct parameters" do
        expect(Search::AlgoliaSearchRequest).to receive(:new).with(search_params).and_call_original
        subject
      end
    end
  end

  describe "#build_suggestions" do
    context "when location matches a location polygon" do
      let(:location) { location_polygon.name }

      context "when vacancies is not empty" do
        let(:vacancies) { double("vacancies") }

        let(:arguments_to_algolia) do
          {
            insidePolygon: location_polygon.polygons["polygons"],
            filters: filter_query,
            hitsPerPage: 10,
            page: page,
          }
        end

        before do
          allow(vacancies).to receive(:empty?).and_return(false)
          mock_algolia_search(vacancies, 1, keyword, arguments_to_algolia)
        end

        it "does not call the buffer suggestions builder" do
          expect(Search::BufferSuggestionsBuilder).not_to receive(:new)
          subject
        end
      end

      context "when vacancies is empty" do
        let(:search_params) do
          {
            keyword: keyword,
            polygons: location_polygon.polygons["polygons"],
            filters: filter_query,
            hits_per_page: 10,
            page: page,
          }
        end

        it "calls the buffer suggestions builder" do
          expect(Search::BufferSuggestionsBuilder).to receive(:new).with(location_polygon.name, search_params).and_call_original
          subject
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
          hits_per_page: 10,
          page: page,
        }
      end

      context "when vacancies is not empty" do
        let(:vacancies) { double("vacancies") }

        let(:arguments_to_algolia) do
          {
            aroundLatLng: Geocoder::DEFAULT_STUB_COORDINATES,
            aroundRadius: convert_miles_to_metres(radius),
            filters: filter_query,
            hitsPerPage: 10,
            page: page,
          }
        end

        before do
          allow(vacancies).to receive(:empty?).and_return(false)
          mock_algolia_search(vacancies, 1, keyword, arguments_to_algolia)
        end

        it "does not call the radius suggestions builder" do
          expect(Search::RadiusSuggestionsBuilder).not_to receive(:new)
          subject
        end
      end

      context "when vacancies is empty" do
        it "calls the radius suggestions builder" do
          expect(Search::RadiusSuggestionsBuilder).to receive(:new).with(radius, search_params).and_call_original
          subject
        end
      end
    end
  end
end
