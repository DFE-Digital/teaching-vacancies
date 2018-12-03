require 'rails_helper'

RSpec.describe UpdateVacancySpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  let(:vacancy) { create(:vacancy) }
  subject(:job) { described_class.perform_later(vacancy.id) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the import_school_data queue' do
    expect(job.queue_name).to eq('update_vacancy_spreadsheet')
  end

  it 'writes to the spreadsheet' do
    stub_const('AUDIT_SPREADSHEET_ID', 'abc1-def2')
    spreadsheet = double(:mock)
    allow(spreadsheet).to receive(:append)
    expect(Spreadsheet::Writer).to receive(:new)
      .with('abc1-def2', UpdateVacancySpreadsheetJob::WORKSHEET_POSITION).and_return(spreadsheet)

    perform_enqueued_jobs { job }
  end
end
