require 'rails_helper'

RSpec.describe SchoolPresenter do

  describe '#location' do
    it 'should return a comma separated location of the school' do
      school = SchoolPresenter.new(create(:school, name: 'Acme School', town: 'Acme', county: 'Kent'))

      expect(school.location).to eq('Acme School, Acme, Kent')
    end

    context 'when one of the properties is empty' do
      it 'should not include that property' do
        school = SchoolPresenter.new(create(:school, name: 'Acme School', town: '', county: 'Kent'))

        expect(school.location).to eq('Acme School, Kent')
      end
    end
  end

  describe '#full_address' do
    it 'should return a comma separated full address of the school' do
      school = SchoolPresenter.new(build(:school, address: '123 Main St', town: 'Acme', county: 'Kent', postcode: 'AB1 2XY'))
      expect(school.full_address).to eq('123 Main St, Acme, Kent, AB1 2XY')
    end

    context 'when one or more of the properties is empty' do
      it 'should not include that property' do
        school = SchoolPresenter.new(build(:school, address: nil, town: 'Chatham', county: 'Kent', postcode: 'AB1 2XY'))
        expect(school.full_address).to eq('Chatham, Kent, AB1 2XY')
      end
    end
  end
end
