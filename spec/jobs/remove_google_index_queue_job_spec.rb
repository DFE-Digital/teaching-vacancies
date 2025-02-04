require "rails_helper"

RSpec.describe RemoveGoogleIndexQueueJob do
  let(:url) { Faker::Internet.url }
  subject(:job) { described_class.perform_later(url) }

  it "executes perform" do
    indexing_service = instance_double(GoogleIndexing, remove: true)
    allow(GoogleIndexing).to receive(:new).with(url).and_return(indexing_service)
    expect(indexing_service).to receive(:remove)

    perform_enqueued_jobs { job }
  end

  it "logs an error message when the indexing service cannot be instantiated" do
    allow(GoogleIndexing).to receive(:new).and_return(nil)
    allow(Rails.logger).to receive(:info).with(any_args)
    expect(Rails.logger).to receive(:info).with("Sidekiq: Aborting Google remove index. Error: No Google API")
    Sidekiq::Testing.inline! do
      described_class.perform_now(url)
    end
  end
end
