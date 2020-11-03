require "rails_helper"

RSpec.describe RefreshCachedVacancyStatisticsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the reset_sessions queue" do
    expect(job.queue_name).to eq("refresh_cached_vacancy_statistics")
  end
end
