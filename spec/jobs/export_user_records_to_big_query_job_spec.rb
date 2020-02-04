require 'rails_helper'

RSpec.describe ExportUserRecordsToBigQueryJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the export_users queue' do
    expect(job.queue_name).to eq('export_users')
  end

  it 'exports user data to big query' do
    export_user_records_to_big_query = double(:export_user_records_to_big_query)
    expect(ExportUserRecordsToBigQuery).to receive(:new) { export_user_records_to_big_query }
    expect(export_user_records_to_big_query).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
