require 'rails_helper'
RSpec.describe SchoolPresenter do
  describe '#location' do
    it 'should return a comma separated location of the school' do
      school = SchoolPresenter.new(create(:school))

      expect(school.location).to eq("#{school.name}, #{school.town}, #{school.county}")
    end

    context 'when one of the properties is empty' do
      it 'should not include that property' do
        school = SchoolPresenter.new(create(:school, town: ''))

        expect(school.location).to eq("#{school.name}, #{school.county}")
      end
    end
  end

  describe '#full_address' do
    it 'should return a comma separated full address of the school' do
      school = SchoolPresenter.new(create(:school))
      expect(school.full_address).to eq("#{school.address}, #{school.town}, #{school.county}, #{school.postcode}")
    end

    context 'when one or more of the properties is empty' do
      it 'should not include that property' do
        school = SchoolPresenter.new(build(:school, address: nil))
        expect(school.full_address).to eq("#{school.town}, #{school.county}, #{school.postcode}")
      end
    end
  end
end
