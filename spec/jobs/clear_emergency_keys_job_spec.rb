require "rails_helper"

RSpec.describe ClearEmergencyLoginKeysJob do
  subject(:job) { described_class.perform_later }

  it "deletes all EmergencyLoginKeys" do
    2.times { create(:emergency_login_key) }
    expect { perform_enqueued_jobs { job } }
        .to change { EmergencyLoginKey.all.size }.from(2).to(0)
  end
end
