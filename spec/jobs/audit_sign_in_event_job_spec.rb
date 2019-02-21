require 'rails_helper'
require 'message_encryptor'

RSpec.describe AuditSignInEventJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(encrypted_data) }
  let(:data) { ['id', Time.zone.now.to_s, 'other-data'] }
  let(:encrypted_data) { MessageEncryptor.new(data).encrypt }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_sign_in_event queue' do
    expect(job.queue_name).to eq('audit_sign_in_event')
  end

  it 'encrypts the data' do
    stub_const('AUDIT_SPREADSHEET_ID', 'abc1-def2')
    spreadsheet = double(:mock)
    expect(Spreadsheet::Writer).to receive(:new)
      .with('abc1-def2', AuditSignInEventJob::WORKSHEET_POSITION).and_return(spreadsheet)
    expect(spreadsheet).to receive(:append_row).with(data)

    perform_enqueued_jobs { job }
  end
end
