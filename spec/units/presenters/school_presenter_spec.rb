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

  describe '#school_size' do
    it 'returns the number of pupils when available' do
      school = SchoolPresenter.new(build(:school, gias_data: { 'NumberOfPupils': 17, 'SchoolCapacity': 20 }))

      expect(school.school_size).to eq('17 pupils enrolled')
    end

    it 'falls back to returning the capacity of the school when number of pupils unavailable' do
      school = SchoolPresenter.new(build(:school, gias_data: { 'SchoolCapacity': 20 }))

      expect(school.school_size).to eq('Up to 20 pupils')
    end

    it 'defaults to a no-information message otherwise' do
      school = SchoolPresenter.new(build(:school, gias_data: {}))

      expect(school.school_size).to eq(I18n.t('schools.no_information'))
    end
  end

  describe '#ofsted_report' do
    it 'returns a link to the ofsted report' do
      school = SchoolPresenter.new(build(:school, gias_data: { 'URN': 100000 }))

      expect(school.ofsted_report).to eq(SchoolPresenter::OFSTED_REPORT_ENDPOINT + '100000')
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

  describe '#age_range' do
    it 'should return the age range of the school' do
      min = 10
      max = 15
      school = SchoolPresenter.new(create(:school, minimum_age: min, maximum_age: max))
      expect(school.age_range).to eq("#{school.minimum_age} to #{school.maximum_age}")
    end

    context 'when the age range is not present' do
      it 'should show that the age range is not given' do
        school = SchoolPresenter.new(build(:school, minimum_age: nil, maximum_age: nil))
        expect(school.age_range).to eq(I18n.t('schools.not_given'))
      end
    end
  end

  describe '#school_type_with_religious_character' do
    let(:academy) { build(:academy, gias_data: { 'ReligiousCharacter (name)': 'Does not apply' }) }
    let(:catholic) { build(:school, gias_data: { 'ReligiousCharacter (name)': 'Roman Catholic' }) }
    let(:secular) { build(:academy, gias_data: { 'ReligiousCharacter (name)': 'Does not apply' }) }

    it 'singularizes the school_type' do
      school_presenter = SchoolPresenter.new(academy)
      expect(school_presenter.school_type_with_religious_character).to match(/Academy/)
    end

    it 'links the school type with the religious character' do
      school_presenter = SchoolPresenter.new(catholic)
      expect(school_presenter.school_type_with_religious_character).to match(/Roman Catholic/)
    end

    context 'when the school has no religious character' do
      it 'returns only the school type' do
        school_presenter = SchoolPresenter.new(secular)
        expect(school_presenter.school_type_with_religious_character)
          .to eq(secular.school_type.label.singularize)
      end
    end
  end
end
