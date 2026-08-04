require "rails_helper"

RSpec.describe ApplicationJob do
  before { stub_const("TestApplicationJob", Class.new(described_class) { def perform; end }) }

  describe "rescue handler ordering" do
    # Handlers are matched last-registered-first, and ActiveJob::DeserializationError
    # is a StandardError, so the catch-all retry must be registered before the discard.
    it "registers the catch-all retry before the more specific discard" do
      expect(described_class.rescue_handlers.map(&:first))
        .to eq(%w[StandardError ActiveJob::DeserializationError])
    end
  end

  describe "discarding deserialization errors" do
    it "discards without retrying when the job arguments can no longer be deserialized" do
      attempts = 0
      TestApplicationJob.define_method(:perform) do
        attempts += 1
        begin
          raise "record not found"
        rescue StandardError
          raise ActiveJob::DeserializationError
        end
      end

      expect {
        perform_enqueued_jobs(at: 1.hour.from_now) { TestApplicationJob.perform_later }
      }.not_to raise_error

      expect(attempts).to eq(1)
      expect(enqueued_jobs).to be_empty
    end
  end

  describe "retrying other errors" do
    it "re-enqueues instead of failing, then succeeds on retry" do
      attempts = 0
      TestApplicationJob.define_method(:perform) do
        attempts += 1
        raise "transient failure" if attempts == 1
      end

      expect {
        perform_enqueued_jobs(at: 1.hour.from_now) { TestApplicationJob.perform_later }
      }.not_to raise_error

      expect(attempts).to eq(2)
    end
  end
end
