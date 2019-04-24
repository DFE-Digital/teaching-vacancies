require 'rails_helper'

RSpec.describe AddVacancyPublishFeedbackToSpreadsheetJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the audit_vacancy_publish_feedback queue' do
    expect(job.queue_name).to eq('audit_vacancy_publish_feedback')
  end

  it 'writes to the spreadsheet' do
    add_vacancy_publish_feedback_to_spreadsheet = double(:add_vacancy_publish_feedback_to_spreadsheet)
    expect(AddVacancyPublishFeedbackToSpreadsheet).to receive(:new) { add_vacancy_publish_feedback_to_spreadsheet }
    expect(add_vacancy_publish_feedback_to_spreadsheet).to receive(:run!)

    perform_enqueued_jobs { job }
  end
end
