require 'rails_helper'

RSpec.describe ImportCSVToBigQueryJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the import_csv queue' do
    expect(job.queue_name).to eq('import_csv')
  end

  it 'calls the import csv to Big Query class' do
    csv_to_big_query = double(:csv_to_big_query)
    expect(ImportCSVToBigQuery).to receive(:new) { csv_to_big_query }
    expect(csv_to_big_query).to receive(:load)

    perform_enqueued_jobs { job }
  end
end
