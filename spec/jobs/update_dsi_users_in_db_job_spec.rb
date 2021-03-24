require "rails_helper"
require "update_dsi_users_in_db_job"

RSpec.describe UpdateDsiUsersInDbJob do
  subject(:job) { described_class.perform_later }

  it "executes perform" do
    update_dsi_users_in_db = double(:mock)
    expect(UpdateDsiUsersInDb).to receive(:new).and_return(update_dsi_users_in_db)
    expect(update_dsi_users_in_db).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
