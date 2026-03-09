require "rails_helper"

RSpec.describe FilteredMailPayload do
  subject { described_class.new(formatter, event) }

  let(:formatter) do
    instance_double(
      RailsSemanticLogger::ActionMailer::LogSubscriber::EventFormatter,
      mailer: "TestMailer",
      action: "test_action",
      date: "2026-03-09",
      log_duration?: true,
    )
  end

  let(:subscription) do
    create(:subscription,
           email: "leaked@example.com",
           frequency: :daily,
           search_criteria: { "location" => "London", "keyword" => "Teacher" })
  end

  let(:event_payload) do
    {
      message_id: "abc123",
      perform_deliveries: true,
      subject: "Test Subject",
      to: ["user@example.com"],
      from: ["noreply@example.com"],
      bcc: nil,
      cc: nil,
      args: [subscription], # ActiveRecord object
    }
  end

  let(:event) do
    instance_double(
      ActiveSupport::Notifications::Event,
      name: "deliver.action_mailer",
      duration: 45.67,
      payload: event_payload,
    )
  end

  describe "#filtered_payload" do
    let(:result) { subject.filtered_payload }

    it "returns a hash with filtered mailer data" do
      expect(result[:mailer]).to eq("TestMailer")
      expect(result[:action]).to eq("test_action")
      expect(result[:subject]).to eq("[FILTERED]")
      expect(result[:to]).to eq("[FILTERED]")
      expect(result[:message_id]).to eq("[FILTERED]")
      expect(result[:from]).to eq(["noreply@example.com"])
      expect(result[:perform_deliveries]).to be(true)
      expect(result[:duration]).to eq(45.67)
    end

    context "when log_duration? is false" do
      before do
        allow(formatter).to receive(:log_duration?).and_return(false)
      end

      it "does not include duration" do
        expect(result).not_to have_key(:duration)
      end
    end

    describe "args filtering with ActiveRecord objects" do
      it "filters the args" do
        args = result[:args]
        expect(args.first["email"]).to eq("[FILTERED]")
        expect(args.first["id"]).to eq("[FILTERED]")
        expect(args.first["frequency"]).to eq("daily")
        expect(args.first["search_criteria"]).to eq({
          "location" => "London",
          "keyword" => "Teacher",
        })
      end

      context "when args contains non-ActiveRecord objects" do
        let(:event_payload) do
          {
            message_id: "abc123",
            perform_deliveries: true,
            subject: "Test Subject",
            to: ["user@example.com"],
            from: ["noreply@example.com"],
            bcc: nil,
            cc: nil,
            args: [{ "key" => "value" }],
          }
        end

        it "handles plain hashes correctly" do
          args = result[:args]
          expect(args).to eq([{ "key" => "value" }])
        end
      end

      context "when args is empty" do
        let(:event_payload) do
          {
            message_id: "abc123",
            perform_deliveries: true,
            subject: "Test Subject",
            to: ["user@example.com"],
            from: ["noreply@example.com"],
            bcc: nil,
            cc: nil,
            args: [],
          }
        end

        it "returns an empty array" do
          expect(result[:args]).to eq([])
        end
      end

      context "when args is nil" do
        let(:event_payload) do
          {
            message_id: "abc123",
            perform_deliveries: true,
            subject: "Test Subject",
            to: ["user@example.com"],
            from: ["noreply@example.com"],
            bcc: nil,
            cc: nil,
            args: nil,
          }
        end

        it "handles nil gracefully" do
          expect(result[:args]).to be_nil
        end
      end
    end
  end
end
