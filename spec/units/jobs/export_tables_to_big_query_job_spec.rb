require 'rails_helper'

RSpec.describe ExportTablesToBigQueryJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the export_tables queue' do
    expect(job.queue_name).to eq('export_tables')
  end

  it 'calls the export tables to big query class' do
    google_cloud_storage = double(:google_cloud_storage)
    expect(ExportTablesToBigQuery).to receive(:new) { google_cloud_storage }
    expect(google_cloud_storage).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
