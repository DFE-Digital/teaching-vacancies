require "rails_helper"

RSpec.describe AuditExpressInterestEventJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(data) }
  let(:data) { [Time.current.to_s, "a-vacancy-id", "01010101", "http://link"] }

  it "creates an AuditData record" do
    expect { perform_enqueued_jobs { job } }.to change { AuditData.count }.by(1)
    expect(AuditData.last.category).to eq("interest_expression")
    expect(AuditData.last.data).to eq(data)
  end
end
