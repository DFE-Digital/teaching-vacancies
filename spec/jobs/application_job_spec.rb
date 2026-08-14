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

  describe "retry backoff" do
    # A flat 3 second wait (the Active Job default) exhausts every attempt in well under a
    # minute, which is not long enough to ride out a briefly unavailable external API.
    it "spaces retries polynomially rather than at a flat 3 seconds" do
      TestApplicationJob.define_method(:perform) { raise "transient failure" }

      job = TestApplicationJob.new

      freeze_time do
        3.times { job.perform_now }

        delays = enqueued_jobs.map { |enqueued| enqueued[:at] - Time.current.to_f }

        expect(delays.first).to be < 5.seconds
        expect(delays.last).to be > 60.seconds
      end
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
