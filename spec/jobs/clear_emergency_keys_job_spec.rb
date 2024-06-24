require "rails_helper"

RSpec.describe ClearEmergencyLoginKeysJob do
  subject(:job) { described_class.perform_later }

  it "deletes all EmergencyLoginKeys" do
    create_list(:emergency_login_key, 2)
    expect { perform_enqueued_jobs { job } }
        .to change { EmergencyLoginKey.all.size }.from(2).to(0)
  end
end
