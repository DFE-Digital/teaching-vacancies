require 'rails_helper'

RSpec.shared_examples 'a search using polygons' do
  it 'sets the correct attributes' do
    expect(subject.location_category).to eql(polygonable_location)
    expect(subject.location_polygon).to eql(location_polygon)
    expect(subject.location_filter).to eql({})
  end
end

RSpec.describe Search::VacancyLocationBuilder do
  subject { described_class.new(location, radius, location_category) }

  let(:location) { nil }
  let(:location_category) { nil }
  let(:point_location) { 'SW1A 1AA' }
  let(:polygonable_location) { 'Bath' }
  let(:polygon_coordinates) { [51.406361958644, -2.3780576677997, 51.4063596372237, -2.3787764623145] }
  let(:radius) { nil }

  let!(:location_polygon) do
    LocationPolygon.create(
      name: polygonable_location.downcase,
      location_type: 'cities',
      boundary: polygon_coordinates,
    )
  end

  describe '#initialize' do
    context 'when a polygonable location is specified' do
      context 'by location parameter' do
        let(:location) { polygonable_location }

        it_behaves_like 'a search using polygons'
      end

      context 'by location_category parameter' do
        let(:location_category) { polygonable_location }

        it_behaves_like 'a search using polygons'
      end

      context 'by location_category parameter and location parameter' do
        let(:location) { polygonable_location }
        let(:location_category) { polygonable_location }

        it_behaves_like 'a search using polygons'
      end

      context 'and polygon coordinate lookup fails (for large areas)' do
        let(:location_category) { 'North West' }

        it 'missing polygon is true' do
          expect(subject.location_category).to eq 'North West'
          expect(subject.location_polygon).to be nil
          expect(subject.location_filter).to eql({})
          expect(subject.missing_polygon).to be true
        end
      end
    end

    context 'when a non-polygonable location is specified' do
      context 'and no radius specified' do
        let(:location) { point_location }

        it 'sets location filter around the location with the default radius' do
          expect(subject.location_category).to be nil
          expect(subject.location_polygon).to be nil
          expect(subject.location_filter).to eql({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: (10 * Search::VacancyLocationBuilder::MILES_TO_METRES).to_i
          })
        end
      end

      context 'and radius specified' do
        let(:location) { point_location }
        let(:radius) { 30 }

        it 'carries out geographical search around a coordinate location with the specified radius' do
          expect(subject.location_category).to be nil
          expect(subject.location_polygon).to be nil
          expect(subject.location_filter).to eql({
            point_coordinates: Geocoder::DEFAULT_STUB_COORDINATES,
            radius: (radius * Search::VacancyLocationBuilder::MILES_TO_METRES).to_i
          })
        end
      end
    end
  end
end
