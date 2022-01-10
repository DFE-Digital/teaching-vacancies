require "rails_helper"

RSpec.describe EmailEvent do
  subject { described_class.new(notify_template, email, uid, jobseeker:, publisher:, ab_tests:) }

  let(:notify_template) { "test_template" }
  let(:email) { "test@example.net" }
  let(:jobseeker) { instance_double(Jobseeker, id: 1234, email: "test@example.net") }
  let(:publisher) { instance_double(Publisher, oid: 4321) }
  let(:uid) { SecureRandom.uuid }
  let(:ab_tests) { { example_AB_test: "present" } }

  describe "#trigger" do
    let(:expected_data) do
      {
        type: :best_ever_email_event,
        occurred_at: "1999-12-31T23:59:59.000000Z",
        data: [
          { key: "uid", value: uid },
          { key: "notify_template", value: notify_template },
          { key: "email_identifier", value: anonymised_form_of("test@example.net") },
          { key: "user_anonymised_jobseeker_id", value: anonymised_form_of("1234") },
          { key: "user_anonymised_publisher_id", value: anonymised_form_of("4321") },
          { key: "foozy", value: "barzy" },
        ],
        request_ab_tests: [{ test: :example_AB_test, variant: "present" }],
      }
    end

    it "enqueues a SendEventToDataWarehouseJob with the expected payload" do
      expect(SendEventToDataWarehouseJob).to receive(:perform_later).with("events", expected_data)

      travel_to(Time.zone.local(1999, 12, 31, 23, 59, 59)) do
        subject.trigger(:best_ever_email_event, foozy: "barzy")
      end
    end
  end
end
