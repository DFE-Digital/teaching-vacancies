require 'rails_helper'

RSpec.describe VacancyAlertFilters do
  describe '#initialize' do
    it 'sets the keyword filter if provided' do
      vacancy_filters = described_class.new(keyword: 'geography')
      expect(vacancy_filters.keyword).to eq('geography')
    end

    it 'sets the subject filter if provided' do
      vacancy_filters = described_class.new(subject: 'geography')
      expect(vacancy_filters.subject).to eq('geography')
    end

    it 'sets the job title filter if provided' do
      vacancy_filters = described_class.new(job_title: 'headteacher')
      expect(vacancy_filters.job_title).to eq('headteacher')
    end

    it 'sets the location filter if provided' do
      vacancy_filters = described_class.new(location: 'durham')
      expect(vacancy_filters.location).to eq('durham')
    end

    it 'sets the working pattern filter if provided and valid' do
      vacancy_filters = described_class.new(working_patterns: '["full_time"]')
      expect(vacancy_filters.working_patterns).to eq(['full_time'])
    end

    it 'does not set the working pattern filter if invalid' do
      vacancy_filters = described_class.new(working_patterns: '["home_time"]')
      expect(vacancy_filters.working_patterns).to be_nil
    end

    it 'sets the newly qualified teacher filter if provided' do
      vacancy_filters = described_class.new(newly_qualified_teacher: true)
      expect(vacancy_filters.newly_qualified_teacher).to eq(true)
    end

    it 'sets the education phase filter if provided and valid' do
      vacancy_filters = described_class.new(phases: '["primary"]')
      expect(vacancy_filters.phases).to eq(['primary'])
    end

    it 'does not set the education phase filter if invalid' do
      vacancy_filters = described_class.new(phases: '["kindergarten"]')
      expect(vacancy_filters.phases).to be_nil
    end

    it 'does not set filters for any other given params' do
      vacancy_filters = described_class.new(column: 'expires_on')
      expect { vacancy_filters.column }.to raise_error(NoMethodError)
    end
  end

  describe '#to_hash' do
    it 'returns a hash of the reader attributes' do
      filters = described_class.new(
        location: 'location',
        keyword: 'keyword',
        subject: 'subject',
        job_title: 'job_title',
        radius: 20,
        working_patterns: '["full_time"]',
        newly_qualified_teacher: false,
        phases: '["primary"]',
      )

      result = filters.to_hash

      expect(result).to eql(
        location: 'location',
        keyword: 'keyword',
        subject: 'subject',
        job_title: 'job_title',
        radius: '20',
        working_patterns: ['full_time'],
        newly_qualified_teacher: false,
        phases: ['primary'],
      )
    end
  end

  describe '#any?' do
    it 'returns true if any filters other than radius are set' do
      filters = described_class.new(
        radius: 20
      )

      expect(filters.any?).to be false
    end
  end
end
