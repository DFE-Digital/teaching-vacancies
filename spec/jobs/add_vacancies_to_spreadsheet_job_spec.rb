require 'rails_helper'

RSpec.describe AddVacanciesToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_vacancies queue' do
    expect(job.queue_name).to eq('audit_vacancies')
  end

  it 'writes to the spreadsheet' do
    add_vacancies_to_spreadsheet = double(:add_vacancies_to_spreadsheet)
    expect(AddVacanciesToSpreadsheet).to receive(:new) { add_vacancies_to_spreadsheet }
    expect(add_vacancies_to_spreadsheet).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
