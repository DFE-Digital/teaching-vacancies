require 'rails_helper'

RSpec.describe UpdateAlgoliaIndex, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the export_users queue' do
    expect(job.queue_name).to eq('update_algolia_index')
  end

  it 'invokes Vacancy#update_index!' do
    expect(Vacancy).to receive(:update_index!)
    perform_enqueued_jobs { job }
  end
end
