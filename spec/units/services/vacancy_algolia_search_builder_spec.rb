require 'rails_helper'

RSpec.describe VacancyAlgoliaSearchBuilder do
  subject { described_class.new(params) }

  let(:keyword) { 'maths teacher' }
  let(:location) { 'SW1A 1AA' }
  let(:location_category) { 'London' }
  let(:default_radius) { 10 }

  let(:algolia_search_query) { search_query }
  let(:algolia_search_args) do
    {
      aroundLatLng: location_coordinates,
      aroundRadius: location_radius,
      replica: search_replica,
      hitsPerPage: default_hits_per_page,
      filters: search_filter,
      page: page
    }
  end

  context '#initialize' do
    context '#keyword' do
      let(:params) do
        {
          keyword: keyword
        }
      end

      it 'adds keyword to the search query' do
        expect(subject.search_query).to eql(keyword)
      end
    end

    context '#location' do
      context 'location category specified' do
        let(:params) do
          {
            location_category: location_category
          }
        end

        it 'adds location to the search query and not the location filter' do
          expect(subject.search_query).to eql(location_category)
          expect(subject.location_filter).to eql({})
        end
      end

      context 'location specified' do
        context 'no radius specified' do
          let(:params) do
            {
              location: location
            }
          end

          it 'carries out geographical search around a coordinate location with the default radius' do
            expect(subject.search_query).not_to include(location)
            expect(subject.location_filter).to eql({
              coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
              radius: subject.convert_radius_in_miles_to_metres(default_radius)
            })
          end
        end

        context 'radius specified' do
          let(:radius) { 30 }
          let(:params) do
            {
              location: location,
              radius: radius
            }
          end

          it 'carries out geographical search around a coordinate location with the specified radius' do
            expect(subject.search_query).not_to include(location)
            expect(subject.location_filter).to eql({
              coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
              radius: subject.convert_radius_in_miles_to_metres(radius)
            })
          end
        end
      end

      context 'location specified that is also a location category' do
        let(:params) do
          {
            location: location_category
          }
        end

        it 'adds the location to the search query' do
          expect(subject.search_query).to eql(location_category)
          expect(subject.location_filter).to eql({})
        end
      end
    end

    context '#sort' do
      context 'no sort specified' do
        let(:params) do
          {}
        end

        it 'does not use a search replica' do
          expect(subject.search_replica).to be_nil
        end
      end

      context 'default sort specified' do
        let(:params) do
          {
            jobs_sort: ''
          }
        end

        it 'does not use a search replica' do
          expect(subject.search_replica).to be_nil
        end
      end

      context 'invalid sort specified' do
        let(:params) do
          {
            jobs_sort: 'bad_sort'
          }
        end

        it 'does not use a search replica' do
          expect(subject.search_replica).to be_nil
        end
      end

      context 'valid sort specified' do
        let(:params) do
          {
            jobs_sort: 'publish_on_desc'
          }
        end

        it 'uses the correct search replica' do
          expect(subject.search_replica).to eql("Vacancy_test#{ENV.fetch('GITHUB_RUN_ID', '')}_publish_on_desc")
        end
      end
    end
  end

  context '#call' do
    @expired_now = Time.zone.now.to_datetime.to_i
    Timecop.freeze(@expired_now)

    let(:sort_by) { '' }
    let(:search_replica) { nil }
    let(:default_hits_per_page) { 10 }
    let(:search_filter) do
      'listing_status:published AND '\
      "publication_date_timestamp <= #{Time.zone.today.to_datetime.to_i} AND "\
      "expires_at_timestamp > #{@expired_now}"
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

    before do
      allow_any_instance_of(VacancyAlgoliaSearchBuilder).to receive(:expired_now_filter).and_return(@expired_now)
      mock_algolia_search('vacancies', algolia_search_query, algolia_search_args)
    end

    context 'a location category search' do
      let(:location) { 'London' }
      let(:search_query) { "#{keyword} #{location}" }
      let(:location_coordinates) { nil }
      let(:location_radius) { nil }

      it 'carries out search with correct parameters' do
        subject.call
        expect(subject.vacancies).to eql('vacancies')
      end
    end

    context 'a geographical radius location search' do
      let(:search_query) { keyword }
      let(:location_coordinates) { Geocoder::DEFAULT_STUB_COORDINATES }
      let(:location_radius) { subject.convert_radius_in_miles_to_metres(default_radius) }

      it 'carries out search with correct criteria' do
        subject.call
        expect(subject.vacancies).to eql('vacancies')
      end
    end
  end
end
