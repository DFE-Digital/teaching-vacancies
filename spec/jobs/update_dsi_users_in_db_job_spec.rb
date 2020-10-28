require 'rails_helper'
require 'update_dsi_users_in_db_job'

RSpec.describe UpdateDsiUsersInDbJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the update_dsi_users_in_db queue' do
    expect(job.queue_name).to eq('update_dsi_users_in_db')
  end

  it 'executes perform' do
    update_dsi_users_in_db = double(:mock)
    expect(UpdateDfeSignInUsers).to receive(:new).and_return(update_dsi_users_in_db)
    expect(update_dsi_users_in_db).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
