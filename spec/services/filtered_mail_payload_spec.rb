require "rails_helper"

RSpec.describe FilteredMailPayload do
  let(:formatter) { double("formatter", mailer: "TestMailer", action: "test_action", date: "2026-03-09", log_duration?: true) }
  let(:event_payload) do
    {
      message_id: "abc123",
      perform_deliveries: true,
      subject: "Test Subject",
      to: ["user@example.com"],
      from: ["noreply@example.com"],
      bcc: nil,
      cc: nil,
      args: [
        {
          email: "leakedemail@hotmail.com",
          id: "dbcc5615-71be-4b12-be48-e9374907b60e",
          frequency: "daily",
          search_criteria: {
            location: "123 Main St",
            keyword: "Teacher",
          },
        },
      ],
    }
  end
  let(:event) do
    double(
      "event",
      name: "deliver.action_mailer",
      duration: 45.67,
      payload: event_payload,
    )
  end

  subject { described_class.new(formatter, event) }

  describe "#filtered_payload" do
    let(:result) { subject.filtered_payload }

    it "returns a hash with filtered mailer data" do
      expect(result).to be_a(Hash)
      expect(result[:event_name]).to eq("[FILTERED]")
      expect(result[:mailer]).to eq("TestMailer")
      expect(result[:action]).to eq("test_action")
    end

    it "filters sensitive email fields" do
      expect(result[:subject]).to eq("[FILTERED]")
      expect(result[:to]).to eq("[FILTERED]")
      expect(result[:message_id]).to eq("[FILTERED]")
    end

    it "does not filter non-sensitive fields" do
      expect(result[:from]).to eq(["noreply@example.com"])
      expect(result[:perform_deliveries]).to eq(true)
    end

    it "includes duration when log_duration? is true" do
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

    describe "args filtering" do
      it "recursively filters sensitive keys within args" do
        args = result[:args]
        expect(args).to be_an(Array)
        expect(args.first[:email]).to eq("[FILTERED]")
        expect(args.first[:id]).to eq("[FILTERED]")
      end

      it "preserves non-sensitive data within args" do
        args = result[:args]
        expect(args.first[:frequency]).to eq("daily")
        expect(args.first[:search_criteria]).to eq({
          location: "123 Main St",
          keyword: "Teacher",
        })
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
    end
  end
end
