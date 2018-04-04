require 'rails_helper'

RSpec.describe Permission, type: :model do
  describe '#valid?' do
    before(:each) do
      stub_const('Permission::USER_TO_SCHOOL_MAPPING', 'user-id' => 'school-urn')
    end

    context 'when the identifier is known' do
      it 'returns true' do
        result = described_class.new(identifier: 'user-id').valid?
        expect(result).to eq(true)
      end
    end

    context 'when the identifier is not known' do
      it 'returns false' do
        result = described_class.new(identifier: 'unknown-id').valid?
        expect(result).to eq(false)
      end
    end

    context 'when the identifier is nil' do
      it 'returns false' do
        result = described_class.new(identifier: nil).valid?
        expect(result).to eq(false)
      end
    end
  end

  describe '#school_urn' do
    before(:each) do
      stub_const('Permission::USER_TO_SCHOOL_MAPPING', 'user-id' => 'school-urn')
    end

    it 'returns the value that matches the identifier' do
      result = described_class.new(identifier: 'user-id').school_urn
      expect(result).to eq('school-urn')
    end

    context 'when the identifier does not match' do
      it 'returns nil' do
        result = described_class.new(identifier: 'unknown-id').school_urn
        expect(result).to eq(nil)
      end
    end
  end
end
