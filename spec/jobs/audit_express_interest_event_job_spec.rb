require "rails_helper"

RSpec.describe AuditExpressInterestEventJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(data) }
  let(:data) { [Time.zone.now.to_s, "a-vacancy-id", "01010101", "http://link"] }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the audit_express_interest_event  queue" do
    expect(job.queue_name).to eq("audit_express_interest_event")
  end

  it "creates an AuditData record" do
    expect { perform_enqueued_jobs { job } }.to change { AuditData.count }.by(1)
    expect(AuditData.last.category).to eq("interest_expression")
    expect(AuditData.last.data).to eq(data)
  end
end
