require 'rails_helper'

RSpec.describe AuditSubscriptionCreationJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(data) }
  let(:data) { SubscriptionPresenter.new(subscription).to_row }
  let(:subscription) { create(:subscription, search_criteria: { keyword: 'english' }.to_json) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_subscription_creation queue' do
    expect(job.queue_name).to eq('audit_subscription_creation')
  end

  it 'creates an AuditData record' do
    expect { perform_enqueued_jobs { job } }.to change { AuditData.all.count }.by(1)
  end

  it 'adds the correct data' do
    perform_enqueued_jobs { job }

    audit_data = AuditData.last

    expect(audit_data.category).to eq('subscription_creation')
    expect(audit_data.data).to eq(data.stringify_keys)
  end
end
