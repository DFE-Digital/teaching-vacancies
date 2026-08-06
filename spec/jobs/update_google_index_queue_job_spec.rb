require "rails_helper"

RSpec.describe UpdateGoogleIndexQueueJob do
  let(:url) { Faker::Internet.url }
  subject(:job) { described_class.perform_later(url) }

  it "executes perform" do
    indexing_service = instance_double(GoogleIndexing, remove: true)
    allow(GoogleIndexing).to receive(:new).with(url).and_return(indexing_service)
    expect(indexing_service).to receive(:update)

    described_class.perform_now(url)
  end

  it "logs an error message when the indexing service cannot be instantiated" do
    allow(GoogleIndexing).to receive(:new).and_return(nil)
    allow(Rails.logger).to receive(:info).with(any_args)
    expect(Rails.logger).to receive(:info).with("Aborting Google update index. Error: No Google API")
    described_class.perform_now(url)
  end

  it "logs and swallows a SystemExit raised by the indexing service" do
    indexing_service = instance_double(GoogleIndexing)
    allow(GoogleIndexing).to receive(:new).with(url).and_return(indexing_service)
    allow(indexing_service).to receive(:update).and_raise(SystemExit, "boom")
    expect(Rails.logger).to receive(:info).with("Aborting Google update index. Error: boom")

    expect { described_class.new.perform(url) }.not_to raise_error
  end

  it "logs and re-raises a StandardError raised by the indexing service" do
    indexing_service = instance_double(GoogleIndexing)
    allow(GoogleIndexing).to receive(:new).with(url).and_return(indexing_service)
    allow(indexing_service).to receive(:update).and_raise(StandardError, "boom")
    expect(Rails.logger).to receive(:error).with("Google indexing error: boom")

    expect { described_class.new.perform(url) }.to raise_error(StandardError, "boom")
  end

  context "when DisableIntegrations is enabled", :disable_integrations do
    it "does not perform the job" do
      expect(GoogleIndexing).not_to receive(:new)
      described_class.perform_now(url)
    end
  end
end
