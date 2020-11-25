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

  let(:polygonable_location) { "Bath" }
  let(:polygon_coordinates) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }
  let(:keyword) { "maths teacher" }
  let(:location) { "" }
  let(:radius) { "" }
  let(:location_category) { nil }
  let(:jobs_sort) { "" }
  let(:hits_per_page) { nil }
  let(:page) { 1 }
  let(:filter_query) { Search::FiltersBuilder.new(form_hash).filter_query }

  let!(:location_polygon) do
    LocationPolygon.create(name: polygonable_location.downcase, location_type: "cities", boundary: polygon_coordinates)
  end

  describe "#build_location_search" do
    let(:location) { polygonable_location }

    context "when a location search polygon is missing" do
      before { allow_any_instance_of(Search::LocationBuilder).to receive(:missing_polygon).and_return(true) }

      it "appends location to the keyword" do
        expect(subject.keyword).to eql("maths teacher Bath")
      end

      it "appends location to keyword in the active hash" do
        expect(subject.only_active_to_hash[:keyword]).to eql("maths teacher Bath")
      end
    end

    context "when a location_category_search is carried out" do
      before { allow_any_instance_of(Search::LocationBuilder).to receive(:location_category_search?).and_return(true) }

      it "sets location_category in the active params hash" do
        expect(subject.only_active_to_hash[:location_category]).to eql("Bath")
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
      let(:location) { polygonable_location }
      let(:search_params) do
        {
          keyword: keyword,
          polygon: [polygon_coordinates],
          filters: filter_query,
          hits_per_page: 10,
          page: page,
        }
      end

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
          radius: Search::LocationBuilder.convert_radius_in_miles_to_metres(radius),
          filters: filter_query,
          hits_per_page: 10,
          page: page,
        }
      end

      before { allow(Search::SuggestionsBuilder).to receive_message_chain(:new, :radius_suggestions) }

      it "calls algolia search with the correct parameters" do
        expect(Search::AlgoliaSearchRequest).to receive(:new).with(search_params).and_call_original
        subject
      end
    end
  end

  describe "#build_suggestions" do
    context "when location matches a location polygon" do
      let(:location) { polygonable_location }

      it "does not call suggestions builder" do
        expect(Search::SuggestionsBuilder).not_to receive(:new)
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
          radius: Search::LocationBuilder.convert_radius_in_miles_to_metres(radius),
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
            aroundRadius: Search::LocationBuilder.convert_radius_in_miles_to_metres(10),
            filters: filter_query,
            hitsPerPage: 10,
            page: 1,
          }
        end

        before do
          allow(vacancies).to receive(:empty?).and_return(false)
          mock_algolia_search(vacancies, 1, keyword, arguments_to_algolia)
        end

        it "does not call suggestions builder" do
          expect(Search::SuggestionsBuilder).not_to receive(:new)
          subject
        end
      end

      context "when vacancies is empty" do
        it "calls suggestions builder" do
          expect(Search::SuggestionsBuilder).to receive(:new).with(search_params, radius).and_call_original
          subject
        end
      end
    end
  end
end
