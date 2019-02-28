require 'rails_helper'

RSpec.describe AddAuditDataToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(category) }
  let(:category) { 'vacancies' }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_spreadsheet queue' do
    expect(job.queue_name).to eq('audit_spreadsheet')
  end

  it 'calls the add audit data class' do
    add_audit_data = double(run!: true)
    expect(AddAuditDataToSpreadsheet).to receive(:new).with(category) { add_audit_data }
    expect(add_audit_data).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
