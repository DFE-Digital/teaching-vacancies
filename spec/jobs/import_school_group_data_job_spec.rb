require 'rails_helper'

RSpec.describe ImportSchoolGroupDataJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the import_school_group_data queue' do
    expect(job.queue_name).to eq('import_school_group_data')
  end

  it 'executes perform' do
    import_school_group_data = double(:mock)
    expect(ImportSchoolGroupData).to receive(:new).and_return(import_school_group_data)
    expect(import_school_group_data).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
