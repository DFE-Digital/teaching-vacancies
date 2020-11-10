require "rails_helper"

RSpec.shared_examples "a search in the base Vacancy index" do
  it "does not use any search replica" do
    expect(subject.search_replica).to be_nil
  end
end

RSpec.shared_examples "a search in the default search replica" do
  it "uses the default search replica" do
    expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_publish_on_desc")
  end
end

RSpec.describe Search::VacancySearchBuilder do
  subject { described_class.new(params) }

  let(:keyword) { "maths teacher" }
  let(:location) { nil }
  let(:point_location) { "SW1A 1AA" }
  let(:polygonable_location) { "Bath" }
  let(:polygon_coordinates) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }
  let(:default_radius) { 10 }

  let!(:location_polygon) do
    LocationPolygon.create(
      name: polygonable_location.downcase,
      location_type: "cities",
      boundary: polygon_coordinates,
    )
  end

  describe "#initialize" do
    context "keyword param" do
      let(:params) { { keyword: keyword } }

      it "initializes keyword attribute" do
        expect(subject.keyword).to eql(keyword)
      end
    end

    context "when a location search polygon is missing" do
      let(:params) { { keyword: keyword, location: polygonable_location } }

      before do
        allow_any_instance_of(Search::VacancyLocationBuilder).to receive(:missing_polygon).and_return(true)
      end

      it "appends location to the keyword" do
        expect(subject.keyword).to eql("maths teacher Bath")
      end

      it "appends location to keyword in the active params hash" do
        expect(subject.only_active_to_hash[:keyword]).to eql("maths teacher Bath")
      end
    end

    context "when a location_category_search is carried out" do
      let(:params) { { keyword: keyword, location: polygonable_location } }

      before do
        allow_any_instance_of(Search::VacancyLocationBuilder).to receive(:location_category_search?)
                                                              .and_return(true)
      end

      it "sets location_category in the active params hash" do
        expect(subject.only_active_to_hash[:location_category]).to eql("Bath")
      end
    end

    context "sorting" do
      let(:keyword) { nil }
      let(:jobs_sort) { "" }
      let(:params) { { keyword: keyword, location: location, jobs_sort: jobs_sort } }

      describe "default sort strategies per scenario when: no sort strategy is specified," do
        context "and a keyword is specified," do
          let(:keyword) { "maths teacher" }
          context "and a location is specified," do
            let(:location) { point_location }
            it_behaves_like "a search in the base Vacancy index"
          end

          context "and a location is NOT specified," do
            it_behaves_like "a search in the base Vacancy index"
          end
        end

        context "and a keyword is NOT specified," do
          context "and a location is specified," do
            let(:location) { point_location }
            it_behaves_like "a search in the default search replica"
          end

          context "and a location is NOT specified," do
            it_behaves_like "a search in the default search replica"

            context "with jobs_sort param present but empty," do
              let(:jobs_sort) { "" }
              it_behaves_like "a search in the default search replica"
            end
          end
        end
      end

      context "when an invalid sort strategy is specified," do
        let(:jobs_sort) { "worst_listing" }
        it_behaves_like "a search in the default search replica"
      end

      context "when a valid non-default sort strategy is specified," do
        let(:jobs_sort) { "expires_at_desc" }

        it "uses the specified search replica" do
          expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_expires_at_desc")
        end

        context "and a keyword is specified," do
          let(:keyword) { "maths teacher" }

          it "uses the specified search replica" do
            expect(subject.search_replica).to eql("#{Indexable::INDEX_NAME}_expires_at_desc")
          end
        end
      end
    end
  end

  describe "#call" do
    let!(:expired_now) { Time.current }
    let(:sort_by) { "" }
    let(:search_replica) { nil }
    let(:default_hits_per_page) { 10 }
    let(:search_filter) do
      "(publication_date_timestamp <= #{Date.current.to_time.to_i} AND "\
       "expires_at_timestamp > #{expired_now.to_time.to_i})"
    end
    let(:page) { 1 }

    let(:params) do
      {
        keyword: keyword,
        location: location,
        jobs_sort: sort_by,
        page: page,
      }
    end

    let(:vacancies) { double("vacancies").as_null_object }

    let(:expected_algolia_search_args) do
      {
        aroundLatLng: location_point_coordinates,
        aroundRadius: location_radius,
        insidePolygon: location_polygon_boundary,
        replica: search_replica,
        hitsPerPage: default_hits_per_page,
        filters: search_filter,
        page: page,
      }
    end

    before do
      mock_algolia_search(vacancies, keyword, expected_algolia_search_args)
    end

    context "a location category search" do
      let(:location) { polygonable_location }
      let(:location_point_coordinates) { nil }
      let(:location_radius) { nil }
      let(:location_polygon_boundary) { [polygon_coordinates] }

      it "carries out search with correct parameters" do
        subject.call
        expect(subject.vacancies).to eql(vacancies)
      end
    end

    context "a geographical radius location search" do
      let(:location) { point_location }
      let(:location_point_coordinates) { Geocoder::DEFAULT_STUB_COORDINATES }
      let(:location_radius) { (default_radius * Search::VacancyLocationBuilder::MILES_TO_METRES).to_i }
      let(:location_polygon_boundary) { nil }

      it "carries out search with correct criteria" do
        subject.call
        expect(subject.vacancies).to eql(vacancies)
      end
    end
  end

  describe "#build_stats" do
    let(:params) { {} }
    let(:page) { 0 }
    let(:pages) { 6 }
    let(:results_per_page) { 10 }
    let(:total_results) { 57 }

    it "returns the correct array" do
      expect(subject.send(:build_stats, page, pages, results_per_page, total_results)).to eql(
        [1, 10, total_results],
      )
    end

    context "there are no results" do
      let(:total_results) { 0 }

      it "returns the correct array" do
        expect(subject.send(:build_stats, page, pages, results_per_page, total_results)).to eql(
          [0, 0, total_results],
        )
      end
    end

    context "the last page" do
      let(:page) { 5 }

      it "returns the correct array" do
        expect(subject.send(:build_stats, page, pages, results_per_page, total_results)).to eql(
          [51, total_results, total_results],
        )
      end
    end
  end
end
