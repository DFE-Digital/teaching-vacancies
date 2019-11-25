require 'rails_helper'

RSpec.describe 'rake spreadsheets:update', type: :task do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the vacancy job' do
    expect { task.execute }.to have_enqueued_job(AddVacanciesToSpreadsheetJob)
  end

  it 'queues the subscription creation job' do
    expect { task.execute }.to have_enqueued_job(AddAuditDataToSpreadsheetJob).with('subscription_creation')
  end

  it 'queues the vacancy creation feedback job' do
    expect { task.execute }.to have_enqueued_job(AddVacancyPublishFeedbackToSpreadsheetJob)
  end

  it 'queues the general feedback job' do
    expect { task.execute }.to have_enqueued_job(AddGeneralFeedbackToSpreadsheetJob)
  end
end
