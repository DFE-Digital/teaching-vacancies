require 'rails_helper'

RSpec.describe AddDSIApproversToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the dsi approver data queue' do
    expect(job.queue_name).to eq('dsi_approver_data')
  end

  it 'writes to the spreadsheet' do
    add_dsi_approvers_to_spreadsheet = double(:add_dsi_approvers_to_spreadsheet)
    expect(AddDSIApproversToSpreadsheet).to receive(:new) { add_dsi_approvers_to_spreadsheet }
    expect(add_dsi_approvers_to_spreadsheet).to receive(:all_service_approvers)

    perform_enqueued_jobs { job }
  end
end
