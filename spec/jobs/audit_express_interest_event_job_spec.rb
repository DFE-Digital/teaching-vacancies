require 'rails_helper'

RSpec.describe AuditExpressInterestEventJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(data) }
  let(:data) { [Time.zone.now.to_s, 'a-vacancy-id', '01010101', 'http://link'] }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_express_interest_event  queue' do
    expect(job.queue_name).to eq('audit_express_interest_event')
  end

  it 'writes to the spreadsheet' do
    stub_const('AUDIT_SPREADSHEET_ID', 'abc1-def2')
    spreadsheet = double(:mock)
    expect(Spreadsheet::Writer).to receive(:new)
      .with('abc1-def2', AuditExpressInterestEventJob::WORKSHEET_POSITION).and_return(spreadsheet)
    expect(spreadsheet).to receive(:append_row).with(data)

    perform_enqueued_jobs { job }
  end
end
