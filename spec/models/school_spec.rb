require 'rails_helper'

RSpec.describe School, type: :model do
  context 'when there is no previous geolocation' do
    before do
      @school = create(:school, easting: nil, northing: nil)
    end

    context 'when setting a GB easting and northing' do
      before do
        @school.easting = 533498
        @school.northing = 181201
      end

      it 'should set the WGS84 geolocation' do
        expect(@school.geolocation.x).to eql(51.51396894535262)
        expect(@school.geolocation.y).to eql(-0.07751626505544208)
      end
    end

    context 'when setting just a GB easting' do
      before do
        @school.easting = 533498
      end

      it 'should not set a geolocation' do
        expect(@school.geolocation).to eql(nil)
      end
    end

    context 'when setting just a GB northing' do
      before do
        @school.northing = 308885
      end

      it 'should not set a geolocation' do
        expect(@school.geolocation).to eql(nil)
      end
    end
  end

  context 'when there is a previous geolocation' do
    before do
      @school = create(:school, easting: 100, northing: 200)
    end

    context 'when setting a GB easting and northing' do
      before do
        @school.easting = 533498
        @school.northing = 181201
      end

      it 'should update the WGS84 geolocation' do
        expect(@school.geolocation.x).to eql(51.51396894535262)
        expect(@school.geolocation.y).to eql(-0.07751626505544208)
      end
    end

    context 'when setting just a GB easting and no northing' do
      before do
        @school.easting = 533498
        @school.northing = nil
      end

      it 'should not set a geolocation' do
        expect(@school.geolocation).to eql(nil)
      end
    end

    context 'when setting just a GB northing and no easting' do
      before do
        @school.northing = 308885
        @school.easting = nil
      end

      it 'should not set a geolocation' do
        expect(@school.geolocation).to eql(nil)
      end
    end
  end
end
