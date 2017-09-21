require 'rails_helper'

RSpec.describe School, type: :model do
  describe '#full_address' do
    it 'should return a comma separated full address of the school' do
      school = build(:school, address: '123 Main St', town: 'Acme', county: 'Kent', postcode: 'AB1 2XY')
      expect(school.full_address).to eq('123 Main St, Acme, Kent, AB1 2XY')
    end

    context 'when one or more of the properties is empty' do
      it 'should not include that property' do
        school = build(:school, address: nil, town: 'Chatham', county: 'Kent', postcode: 'AB1 2XY')
        expect(school.full_address).to eq('Chatham, Kent, AB1 2XY')
      end
    end
  end
end