require 'rails_helper'

RSpec.describe 'rake data:working_pattern:migrate', type: :task do
  context 'when vacancies with working_pattern set exist' do
    let!(:non_flexible_vacancies) do
      [
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :full_time, flexible_working: nil),
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :part_time, flexible_working: nil)
      ].flatten!
    end

    let!(:flexible_vacancies) do
      [
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :full_time, flexible_working: true),
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :part_time, flexible_working: true)
      ].flatten!
    end

    let!(:vacancies) do
      [
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :full_time),
        create_list(:vacancy, 2, :without_working_patterns, working_pattern: :part_time),
        non_flexible_vacancies,
        flexible_vacancies
      ].flatten!
    end

    it 'sets working_patterns to a single element array of working_pattern' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).working_patterns).to eq([vacancy.working_pattern.to_s])
      end
    end

    it 'leaves working_pattern unchanged' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).working_pattern).to eq(vacancy.working_pattern)
      end
    end

    it 'changes nil flexible_working values to false' do
      task.execute

      non_flexible_vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).flexible_working).to eq(false)
      end
    end

    it 'changes true flexible_working values to nil for part time vacancies only' do
      task.execute

      flexible_vacancies.each do |vacancy|
        new_vacancy = Vacancy.find(vacancy.id)

        if vacancy.part_time?
          expect(new_vacancy.flexible_working).to eq(nil)
        else
          expect(new_vacancy.flexible_working).to eq(vacancy.flexible_working.presence || false)
        end
      end
    end

    it 'sets pro_rata_salary to true for part time vacancies only' do
      task.execute

      vacancies.each do |vacancy|
        new_vacancy = Vacancy.find(vacancy.id)

        if new_vacancy.working_patterns == ['part_time']
          expect(new_vacancy.pro_rata_salary).to eq(true)
        else
          expect(new_vacancy.pro_rata_salary).to eq(nil)
        end
      end
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

    it 'leaves working_pattern unchanged' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).working_pattern).to eq(vacancy.working_pattern)
      end
    end

    it 'leaves flexible_working unchanged' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).flexible_working).to eq(vacancy.flexible_working)
      end
    end

    it 'leaves pro_rata_salary unchanged' do
      task.execute

      vacancies.each do |vacancy|
        expect(Vacancy.find(vacancy.id).pro_rata_salary).to eq(vacancy.pro_rata_salary)
      end
    end
  end
end
