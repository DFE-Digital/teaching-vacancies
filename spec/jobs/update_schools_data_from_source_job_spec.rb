require 'rails_helper'

RSpec.describe UpdateSchoolsDataFromSourceJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the import_school_data queue' do
    expect(job.queue_name).to eq('import_school_data')
  end

  it 'executes perform' do
    update_school_data = double(:mock)
    expect(UpdateSchoolData).to receive(:new).and_return(update_school_data)
    expect(update_school_data).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
