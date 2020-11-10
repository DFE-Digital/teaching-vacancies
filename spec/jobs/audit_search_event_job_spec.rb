require "rails_helper"

RSpec.describe AuditSearchEventJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(data) }
  let(:data) { [Time.current.iso8601.to_s, 1, "", "20", "Physics", "", "", "", nil, nil, "true"] }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the audit_search_event queue" do
    expect(job.queue_name).to eq("audit_search_event")
  end

  it "creates an AuditData record" do
    expect { perform_enqueued_jobs { job } }.to change { AuditData.all.count }.by(1)
  end

  it "adds the correct data" do
    perform_enqueued_jobs { job }

    audit_data = AuditData.last

    expect(audit_data.category).to eq("search_event")
    expect(audit_data.data).to eq(data)
  end
end
