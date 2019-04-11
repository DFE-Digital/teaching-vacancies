require 'rails_helper'

RSpec.describe School, type: :model do
  context 'when there is no previous geolocation' do
    let(:school) { create(:school, easting: nil, northing: nil) }

    context '#urn' do
      it 'must be unique' do
        create(:school, urn: '12345')
        school = build(:school, urn: '12345')
        school.valid?

        expect(school.errors.messages[:urn].first).to eq(I18n.t('errors.messages.taken'))
      end
    end

    context '#geolocation' do
      context 'when setting a GB easting and northing' do
        it 'should set the WGS84 geolocation' do
          school.easting = 533498
          school.northing = 181201

          expect(school.latitude).to eql(51.51396894535262)
          expect(school.longitude).to eql(-0.07751626505544208)
        end
      end

      context 'when setting just a GB easting' do
        it 'should not set a geolocation' do
          school.easting = 533498

          expect(school.latitude).to eql(nil)
          expect(school.longitude).to eql(nil)
        end
      end

      context 'when setting just a GB northing' do
        it 'should not set a geolocation' do
          school.northing = 308885

          expect(school.latitude).to eql(nil)
          expect(school.longitude).to eql(nil)
        end
      end
    end

    context 'when there is a previous geolocation' do
      let(:school) { create(:school, easting: 100, northing: 200) }

      context 'when setting a GB easting and northing' do
        it 'should update the WGS84 geolocation' do
          school.easting = 533498
          school.northing = 181201

          expect(school.latitude).to eql(51.51396894535262)
          expect(school.longitude).to eql(-0.07751626505544208)
        end
      end

      context 'when setting just a GB easting and no northing' do
        it 'should not set a geolocation' do
          school.easting = 533498
          school.northing = nil

          expect(school.latitude).to eql(nil)
          expect(school.longitude).to eql(nil)
        end
      end

      context 'when setting just a GB northing and no easting' do
        it 'should not set a geolocation' do
          school.northing = 308885
          school.easting = nil

          expect(school.latitude).to eql(nil)
          expect(school.longitude).to eql(nil)
        end
      end
    end
  end

  describe '#geolocation?' do
    let(:school) { create(:school, latitude: 51.5139689453526, longitude: -0.07751626505544208) }

    context 'when there is a latitude and longitude' do
      it { expect(school.geolocation?).to eq(true) }
    end

    context 'when there is no latitude' do
      before { school.latitude = nil }

      it { expect(school.geolocation?).to eq(false) }
    end

    context 'when there is no longitude' do
      before { school.longitude = nil }

      it { expect(school.geolocation?).to eq(false) }
    end
  end
end
