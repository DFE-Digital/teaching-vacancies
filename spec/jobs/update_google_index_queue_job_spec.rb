require 'rails_helper'

RSpec.describe UpdateGoogleIndexQueueJob, type: :job do
  include ActiveJob::TestHelper

  let(:url) { Faker::Internet.url }
  subject(:job) { described_class.perform_later(url) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the default queue' do
    expect(job.queue_name).to eq('default')
  end

  it 'executes perform' do
    indexing_service = double(:mock)
    expect(Indexing).to receive(:new).with(url).and_return(indexing_service)
    expect(indexing_service).to receive(:update)

    perform_enqueued_jobs { job }
  end
end
