require 'rails_helper'

RSpec.describe 'rake data:working_pattern:migrate', type: :task do
  context 'when vacancies with working_pattern set exist' do
    let!(:vacancies) do
      [
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :full_time),
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :part_time)
      ].flatten!
    end

    it 'sets working_patterns to a single element array of working_pattern' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).working_patterns).to eq([vacancy.working_pattern.to_s])
      end
    end

    it 'clears working_pattern' do
      task.execute

      expect(Vacancy.where.not(working_pattern: nil).count).to eq(0)
    end
  end

  context 'when vacancies without working_pattern set exist' do
    let!(:vacancies) do
      [
        create_list(:vacancy, 2, working_patterns: ['full_time']),
        create_list(:vacancy, 2, working_patterns: ['job_share']),
        create_list(:vacancy, 2, working_patterns: ['full_time', 'part_time'])
      ].flatten!
    end

    it 'leaves working_patterns unchanged' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).working_patterns).to eq(vacancy.working_patterns)
      end
    end
  end
end
