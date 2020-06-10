require 'rails_helper'

RSpec.describe School, type: :model do
  it { expect(subject.attributes).to include('gias_data') }
  it { expect(described_class.columns_hash['gias_data'].type).to eql(:json) }

  describe '#has_religious_character?' do
    before do
      subject.gias_data = {}.to_json
    end

    it 'returns false when the school has no gias_data' do
      subject.gias_data = nil
      expect(subject.has_religious_character?).to be false
    end

    it 'returns false when the school has no religious_character' do
      allow(subject.gias_data).to receive(:[]).with('ReligiousCharacter (name)').and_return 'Does not apply'
      expect(subject.has_religious_character?).to be false
    end

    it 'returns true when the school has a religious character' do
      allow(subject.gias_data).to receive(:[]).with('ReligiousCharacter (name)').and_return 'Roman Catholic'
      expect(subject.has_religious_character?).to be true
    end
  end

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

    describe 'delegate region_name' do
      it 'should return the region name for the school' do
        region = create(:region, name: 'London')
        school = create(:school, region: region)

        expect(school.region_name).to eq('London')
      end
    end

    context '#geolocation' do
      context 'when setting a GB easting and northing' do
        it 'should set the WGS84 geolocation' do
          school.easting = 533498
          school.northing = 181201

          expect(school.geolocation.x).to eql(51.51396894535262)
          expect(school.geolocation.y).to eql(-0.07751626505544208)
        end
      end

      context 'when setting just a GB easting' do
        it 'should not set a geolocation' do
          school.easting = 533498
          expect(school.geolocation).to eql(nil)
        end
      end

      context 'when setting just a GB northing' do
        it 'should not set a geolocation' do
          school.northing = 308885

          expect(school.geolocation).to eql(nil)
        end
      end
    end

    context 'when there is a previous geolocation' do
      let(:school) { create(:school, easting: 100, northing: 200) }

      context 'when setting a GB easting and northing' do
        it 'should update the WGS84 geolocation' do
          school.easting = 533498
          school.northing = 181201

          expect(school.geolocation.x).to eql(51.51396894535262)
          expect(school.geolocation.y).to eql(-0.07751626505544208)
        end
      end

      context 'when setting just a GB easting and no northing' do
        it 'should not set a geolocation' do
          school.easting = 533498
          school.northing = nil

          expect(school.geolocation).to eql(nil)
        end
      end

      context 'when setting just a GB northing and no easting' do
        it 'should not set a geolocation' do
          school.northing = 308885
          school.easting = nil

          expect(school.geolocation).to eql(nil)
        end
      end
    end
  end
end
