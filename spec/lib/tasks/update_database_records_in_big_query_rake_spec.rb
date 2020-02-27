require 'rails_helper'

RSpec.describe 'rake database_records:in_big_query:update', type: :task do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the export vacancy records to big query job' do
    expect { task.execute }.to have_enqueued_job(ExportDsiUsersToBigQueryJob)
  end
end
