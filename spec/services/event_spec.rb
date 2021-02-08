require "rails_helper"

RSpec.describe Event do
  describe "#trigger" do
    it "enqueues a SendEventToDataWarehouseJob with the expected payload" do
      expect(SendEventToDataWarehouseJob).to receive(:perform_later).with(
        "events",
        type: :reticulated_splines,
        occurred_at: "1999-12-31T23:59:59.000000Z",
        data: [
          { key: "foo", value: "Bar" },
          { key: "baz", value: [1, 2] },
          { key: "params", value: { foo: "bar" }.to_json },
        ],
      )

      travel_to(Time.utc(1999, 12, 31, 23, 59, 59)) do
        subject.trigger(:reticulated_splines, foo: "Bar", baz: [1, 2], params: { foo: "bar" })
      end
    end

    context "when an error occurs when the event is triggered" do
      let(:error) { StandardError.new("Splines are insufficiently reticulated") }

      it "ignores the error but reports it to Rollbar" do
        allow(SendEventToDataWarehouseJob).to receive(:perform_later).and_raise(error)
        expect(Rollbar).to receive(:error).with(error)

        subject.trigger(:reticulated_splines)
      end
    end
  end
end
