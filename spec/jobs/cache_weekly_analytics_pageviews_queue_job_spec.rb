require 'rails_helper'

RSpec.describe CacheWeeklyAnalyticsPageviewsQueueJob, type: :job do
  include ActiveJob::TestHelper

  let(:vacancy) { create(:vacancy) }
  subject(:job) { described_class.perform_later(vacancy.id) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the page_view_collector queue' do
    expect(job.queue_name).to eq('page_view_collector')
  end

  it 'executes perform' do
    analytics_service = double(:mock, pageviews: 0)
    job_path = Rails.application.routes.url_helpers.job_path(vacancy)
    expect(Analytics).to receive(:new).with(job_path, Analytics::ONEWEEKAGO, Analytics::TODAY)
                                      .and_return(analytics_service)
    expect(analytics_service).to receive(:call).and_return(analytics_service)
    expect(analytics_service).to receive(:pageviews).and_return(0)

    perform_enqueued_jobs { job }
  end

  it 'aborts execution when no Google credentials are set' do
    stub_const('GOOGLE_API_JSON_KEY', '')
    Sidekiq::Testing.inline! do
      expect(Analytics).to receive(:new).and_raise(SystemExit, 'No Google API')

      described_class.perform_now(vacancy.id)
    end
  end
end
