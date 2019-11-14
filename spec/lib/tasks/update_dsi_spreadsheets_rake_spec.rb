require 'rails_helper'

RSpec.describe 'rake dsi_spreadsheets:update', type: :task do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the add dsi users to spreadsheet job' do
    expect { task.execute }.to have_enqueued_job(AddDSIUsersToSpreadsheetJob)
  end

  it 'queues the add dsi approvers to spreadsheet job' do
    expect { task.execute }.to have_enqueued_job(AddDSIApproversToSpreadsheetJob)
  end
end
