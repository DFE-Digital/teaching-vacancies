require 'rails_helper'

RSpec.describe LocationCategory, type: :model do
  before do
    create(:school, :in_london, local_authority: 'Camden')
    create(:school, :outside_london, county: 'Somerset')
    stub_const('ALL_LOCATION_CATEGORIES', all_location_categories)
  end

  let(:all_location_categories) { ['London', 'East of England', 'Camden', 'Somerset'].map(&:downcase) }

  describe '.include?' do
    context 'when location is included' do
      it 'returns true' do
        expect(described_class.include?('London')).to be_truthy
      end
    end

    context 'when location is not included' do
      it 'returns true' do
        expect(described_class.include?('Canterbury')).to be_falsey
      end
    end
  end

  describe '.regions' do
    it 'returns regions' do
      expect(described_class.regions).to eq ['London', 'East of England']
    end
  end

  describe '.boroughs' do
    it 'returns boroughs' do
      expect(described_class.boroughs).to eq ['Camden']
    end
  end

  describe '.counties' do
    it 'returns counties' do
      expect(described_class.counties).to eq ['Somerset']
    end
  end
end
