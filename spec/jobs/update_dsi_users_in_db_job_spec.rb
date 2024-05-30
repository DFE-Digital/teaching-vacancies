require "rails_helper"

RSpec.describe UpdateDSIUsersInDbJob do
  subject(:job) { described_class.perform_later }

  it "executes perform" do
    update_dsi_users_in_db = instance_double(Publishers::DfeSignIn::UpdateUsersInDb)
    expect(Publishers::DfeSignIn::UpdateUsersInDb).to receive(:new).and_return(update_dsi_users_in_db)
    expect(update_dsi_users_in_db).to receive(:call)

    perform_enqueued_jobs { job }
  end
end
