require 'rails_helper'

RSpec.shared_examples 'a search in the base Vacancy index' do
  it 'does not use any search replica' do
    expect(subject.search_replica).to be_nil
  end
end

RSpec.shared_examples 'a search in the default search replica' do
  it 'uses the default search replica' do
    expect(subject.search_replica).to eql('Vacancy_publish_on_desc')
  end
end

RSpec.describe VacancyAlgoliaSearchBuilder do
  subject { described_class.new(params) }

  let(:keyword) { 'maths teacher' }
  let(:location) { 'SW1A 1AA' }
  let(:location_category) { 'London' }
  let(:default_radius) { 10 }
  let(:location_polygon) { nil }

  let(:algolia_search_query) { search_query }
  let(:algolia_search_args) do
    {
      aroundLatLng: location_point_coordinates,
      aroundRadius: location_radius,
      insidePolygon: location_polygon,
      replica: search_replica,
      hitsPerPage: default_hits_per_page,
      filters: search_filter,
      page: page
    }
  end

  describe '#initialize' do
    context '#keyword' do
      let(:params) { { keyword: keyword } }

      it 'adds keyword to the search query' do
        expect(subject.search_query).to eql(keyword)
      end
    end

    context '#location' do
      context 'location category specified' do
        let(:params) { { location_category: location_category } }

        it 'adds location to the search query and not the location filter' do
          expect(subject.search_query).to eql(location_category)
          expect(subject.location_filter).to eql({})
        end
      end

      context 'location specified' do
        context 'no radius specified' do
          let(:params) { { location: location } }

          it 'carries out geographical search around a coordinate location with the default radius' do
            expect(subject.search_query).not_to include(location)
            expect(subject.location_filter).to eql({
              point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
              radius: subject.convert_radius_in_miles_to_metres(default_radius)
            })
          end
        end

        context 'radius specified' do
          let(:radius) { 30 }
          let(:params) { { location: location, radius: radius } }

          it 'carries out geographical search around a coordinate location with the specified radius' do
            expect(subject.search_query).not_to include(location)
            expect(subject.location_filter).to eql({
              point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
              radius: subject.convert_radius_in_miles_to_metres(radius)
            })
          end
        end
      end

      context 'location specified that is also a location category' do
        let(:params) { { location: location_category } }

        it 'adds the location to the search query' do
          expect(subject.search_query).to eql(location_category)
          expect(subject.location_filter).to eql({})
        end
      end
    end

    context 'sorting' do
      let(:keyword) { nil }
      let(:jobs_sort) { '' }
      let(:params) do
        { keyword: keyword, location: location, jobs_sort: jobs_sort }
      end

      describe 'default sort strategies per scenario when: no sort strategy is specified,' do
        context 'and a keyword is specified,' do
          let(:keyword) { 'maths teacher' }
          context 'and a location is specified,' do
            it_behaves_like 'a search in the base Vacancy index'
          end

          context 'and a location is NOT specified,' do
            let(:location) { nil }
            it_behaves_like 'a search in the base Vacancy index'
          end
        end

        context 'and a keyword is NOT specified,' do
          context 'and a location is specified,' do
            it_behaves_like 'a search in the default search replica'
          end

          context 'and a location is NOT specified,' do
            let(:location) { nil }
            it_behaves_like 'a search in the default search replica'

            context 'with jobs_sort param present but empty,' do
              let(:jobs_sort) { '' }
              it_behaves_like 'a search in the default search replica'
            end
          end
        end
      end

      context 'when an invalid sort strategy is specified,' do
        let(:jobs_sort) { 'worst_listing' }
        it_behaves_like 'a search in the default search replica'
      end

      context 'when a valid non-default sort strategy is specified,' do
        let(:jobs_sort) { 'expiry_time_desc' }

        it 'uses the specified search replica' do
          expect(subject.search_replica).to eql('Vacancy_expiry_time_desc')
        end

        context 'and a keyword is specified,' do
          let(:keyword) { 'maths teacher' }

          it 'uses the specified search replica' do
            expect(subject.search_replica).to eql('Vacancy_expiry_time_desc')
          end
        end
      end
    end
  end

  describe '#build_stats' do
    let(:params) { {} }
    let(:page) { 0 }
    let(:pages) { 6 }
    let(:results_per_page) { 10 }
    let(:total_results) { 57 }

    it 'returns the correct array' do
      expect(subject.build_stats(page, pages, results_per_page, total_results)).to eql(
        [1, 10, total_results]
      )
    end

    context 'there are no results' do
      let(:total_results) { 0 }

      it 'returns the correct array' do
        expect(subject.build_stats(page, pages, results_per_page, total_results)).to eql(
          [0, 0, total_results]
        )
      end
    end

    context 'the last page' do
      let(:page) { 5 }

      it 'returns the correct array' do
        expect(subject.build_stats(page, pages, results_per_page, total_results)).to eql(
          [51, total_results, total_results]
        )
      end
    end
  end

  describe '#call' do
    let!(:expired_now) { Time.zone.now }
    let(:sort_by) { '' }
    let(:search_replica) { nil }
    let(:default_hits_per_page) { 10 }
    let(:search_filter) do
      'listing_status:published AND '\
      "publication_date_timestamp <= #{Time.zone.today.to_datetime.to_i} AND "\
      "expires_at_timestamp > #{expired_now.to_datetime.to_i}"
    end
    let(:page) { 1 }

    let(:params) do
      {
        keyword: keyword,
        location: location,
        jobs_sort: sort_by,
        page: page
      }
    end

    let(:vacancies) { double('vacancies').as_null_object }

    before do
      travel_to(expired_now)
      allow_any_instance_of(VacancyAlgoliaSearchBuilder)
        .to receive(:expired_now_filter)
        .and_return(expired_now.to_datetime.to_i)
      mock_algolia_search(vacancies, algolia_search_query, algolia_search_args)
    end

    after { travel_back }

    context 'a location category search' do
      let(:location) { 'Bath' }
      let(:search_query) { "#{keyword} #{location}" }
      let(:location_point_coordinates) { nil }
      let(:location_radius) { nil }
      let(:location_polygon) { [[51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145]] }

      it 'carries out search with correct parameters' do
        subject.call
        expect(subject.vacancies).to eql(vacancies)
      end
    end

    context 'a geographical radius location search' do
      let(:search_query) { keyword }
      let(:location_point_coordinates) { Geocoder::DEFAULT_STUB_COORDINATES }
      let(:location_radius) { subject.convert_radius_in_miles_to_metres(default_radius) }

      it 'carries out search with correct criteria' do
        subject.call
        expect(subject.vacancies).to eql(vacancies)
      end
    end
  end
end
