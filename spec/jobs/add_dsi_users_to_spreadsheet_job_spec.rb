require 'rails_helper'

RSpec.describe AddDSIUsersToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the dsi user data queue' do
    expect(job.queue_name).to eq('dsi_user_data')
  end

  it 'writes to the spreadsheet' do
    add_dsi_users_to_spreadsheet = double(:add_dsi_users_to_spreadsheet)
    expect(AddDSIUsersToSpreadsheet).to receive(:new) { add_dsi_users_to_spreadsheet }
    expect(add_dsi_users_to_spreadsheet).to receive(:all_service_users)

    perform_enqueued_jobs { job }
  end
end