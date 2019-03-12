require 'rails_helper'

RSpec.describe AddFeedbackToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }
  let(:data) { [Time.zone.now.to_s, 'vacancy-id', '010101', 5, 'feedback note'] }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_feedback queue' do
    expect(job.queue_name).to eq('audit_feedback')
  end

  it 'writes to the spreadsheet' do
    add_feedback_to_spreadsheet = double(:add_feedback_to_spreadsheet)
    expect(AddFeedbackToSpreadsheet).to receive(:new) { add_feedback_to_spreadsheet }
    expect(add_feedback_to_spreadsheet).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
