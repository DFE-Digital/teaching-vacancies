require "rails_helper"
require "clear_emergency_login_keys_job"

RSpec.describe ClearEmergencyLoginKeysJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the clear_emergency_login_keys queue" do
    expect(job.queue_name).to eq("clear_emergency_login_keys")
  end

  it "deletes all EmergencyLoginKeys" do
    2.times { create(:emergency_login_key) }
    expect { perform_enqueued_jobs { job } }
        .to change { EmergencyLoginKey.all.size }.from(2).to(0)
  end
end
