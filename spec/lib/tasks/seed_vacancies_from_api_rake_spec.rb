require 'rails_helper'
require 'teaching_vacancies_api'

RSpec.describe 'rake data:seed_from_api:vacancies', type: :task do
  it 'queues jobs to add vacancies from the Teaching Vacancies API' do
    vacancies = [double]
    allow(TeachingVacancies::API).to receive(:new).and_return(double(jobs: vacancies))

    vacancies.each do |vacancy|
      expect(SaveJobPostingToVacancyJob).to receive(:perform_later).with(vacancy)
    end

    task.invoke
  end
end
