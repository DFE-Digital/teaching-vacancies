require 'rails_helper'

RSpec.describe ImportTrustDataJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context 'when DisableExpensiveJobs is not enabled' do
    let(:disable_expensive_jobs_enabled?) { false }

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is in the import_trust_data queue' do
      expect(job.queue_name).to eq('import_trust_data')
    end

    it 'executes perform' do
      import_trust_data = double(:mock)
      expect(ImportTrustData).to receive(:new).and_return(import_trust_data)
      expect(import_trust_data).to receive(:run!)

      perform_enqueued_jobs { job }
    end
  end

  context 'when DisableExpensiveJobs is enabled' do
    let(:disable_expensive_jobs_enabled?) { true }

    it 'does not perform the job' do
      expect(ImportTrustData).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
