require "rails_helper"

RSpec.describe RemoveGoogleIndexQueueJob, type: :job do
  include ActiveJob::TestHelper

  let(:url) { Faker::Internet.url }
  subject(:job) { described_class.perform_later(url) }

  it "queues the job" do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it "is in the google_indexing queue" do
    expect(job.queue_name).to eq("google_indexing")
  end

  it "executes perform" do
    indexing_service = double(:mock)
    expect(Indexing).to receive(:new).with(url).and_return(indexing_service)
    expect(indexing_service).to receive(:remove)

    perform_enqueued_jobs { job }
  end

  it "aborts execution when no Google credentials are set" do
    stub_const("GOOGLE_API_JSON_KEY", "")
    Sidekiq::Testing.inline! do
      expect(Indexing).to receive(:new).and_raise(SystemExit, "No Google API")

      described_class.perform_now(url)
    end
  end
end
