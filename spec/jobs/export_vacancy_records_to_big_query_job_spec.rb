require 'rails_helper'

RSpec.describe ExportVacancyRecordsToBigQueryJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the export_vacancies queue' do
    expect(job.queue_name).to eq('export_vacancies')
  end

  it 'exports vacancy data to big query' do
    export_vacancy_records_to_big_query = double(:export_vacancy_records_to_big_query)
    expect(ExportVacancyRecordsToBigQuery).to receive(:new) { export_vacancy_records_to_big_query }
    expect(export_vacancy_records_to_big_query).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
