require 'rails_helper'

RSpec.describe AddGeneralFeedbackToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_general_feedback queue' do
    expect(job.queue_name).to eq('audit_general_feedback')
  end

  it 'writes to the spreadsheet' do
    add_general_feedback_to_spreadsheet = double(:add_general_feedback_to_spreadsheet)
    expect(AddGeneralFeedbackToSpreadsheet).to receive(:new) { add_general_feedback_to_spreadsheet }
    expect(add_general_feedback_to_spreadsheet).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
