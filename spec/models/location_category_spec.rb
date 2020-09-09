require 'rails_helper'

RSpec.describe LocationCategory, type: :model do
  before do
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
end
