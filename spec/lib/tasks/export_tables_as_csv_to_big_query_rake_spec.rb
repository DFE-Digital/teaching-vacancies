require 'rails_helper'

RSpec.describe 'rake tables_as_csv:to_big_query:export', type: :task do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the jobs for converting and exporting the table data as csvs' do
    expect { task.execute }.to have_enqueued_job(ExportTablesToCloudStorageJob)
    expect { task.execute }.to have_enqueued_job(ImportCSVToBigQueryJob)
  end
end
