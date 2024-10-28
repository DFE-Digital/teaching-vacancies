require "rails_helper"

RSpec.describe ClearEmergencyLoginKeysJob do
  subject(:job) { described_class.perform_later }

  let(:publisher) { create(:publisher) }

  it "deletes all EmergencyLoginKeys" do
    2.times { EmergencyLoginKey.create(owner: publisher, not_valid_after: Date.current - 1.day) }
    expect { perform_enqueued_jobs { job } }
        .to change { EmergencyLoginKey.all.size }.from(2).to(0)
  end
end
