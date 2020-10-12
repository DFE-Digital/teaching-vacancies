require 'rails_helper'

RSpec.describe School, type: :model do
  it { expect(subject.attributes).to include('gias_data') }
  it { expect(described_class.columns_hash['gias_data'].type).to eql(:json) }

  it { should have_many(:school_group_memberships) }
  it { should have_many(:school_groups) }

  describe '#religious_character' do
    let(:religious_character) { 'Roman Catholic' }
    let(:gias_data) { { 'ReligiousCharacter (name)' => religious_character } }

    subject { build(:school, gias_data: gias_data) }

    it 'returns religious character' do
      expect(subject.religious_character).to eq 'Roman Catholic'
    end

    context 'when the school has no religious character' do
      let(:religious_character) { 'Does not apply' }

      it 'returns nil' do
        expect(subject.religious_character).to eq nil
      end
    end

    context 'when the school has no gias_data' do
      let(:gias_data) { nil }

      it 'returns nil' do
        expect(subject.religious_character).to eq nil
      end
    end
  end

  context 'when there is no previous geolocation' do
    let(:school) { create(:school, easting: nil, northing: nil) }

    describe '#urn' do
      it 'must be unique' do
        create(:school, urn: '12345')
        school = build(:school, urn: '12345')
        school.valid?

        expect(school.errors.messages[:urn].first).to eq(I18n.t('errors.messages.taken'))
      end
    end

    describe '#geolocation' do
      context 'when setting a GB easting and northing' do
        it 'should set the WGS84 geolocation' do
          school.easting = 533_498
          school.northing = 181_201

          expect(school.geolocation.x).to eql(51.51396894535262)
          expect(school.geolocation.y).to eql(-0.07751626505544208)
        end
      end

      context 'when setting just a GB easting' do
        it 'should not set a geolocation' do
          school.easting = 533_498
          expect(school.geolocation).to eql(nil)
        end
      end

      context 'when setting just a GB northing' do
        it 'should not set a geolocation' do
          school.northing = 308_885

          expect(school.geolocation).to eql(nil)
        end
      end
    end

    context 'when there is a previous geolocation' do
      let(:school) { create(:school, easting: 100, northing: 200) }

      context 'when setting a GB easting and northing' do
        it 'should update the WGS84 geolocation' do
          school.easting = 533_498
          school.northing = 181_201

          expect(school.geolocation.x).to eql(51.51396894535262)
          expect(school.geolocation.y).to eql(-0.07751626505544208)
        end
      end

      context 'when setting just a GB easting and no northing' do
        it 'should not set a geolocation' do
          school.easting = 533_498
          school.northing = nil

          expect(school.geolocation).to eql(nil)
        end
      end

      context 'when setting just a GB northing and no easting' do
        it 'should not set a geolocation' do
          school.northing = 308_885
          school.easting = nil

          expect(school.geolocation).to eql(nil)
        end
      end
    end
  end
end
