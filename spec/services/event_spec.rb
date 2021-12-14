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
          { key: "pi", value: 3.14 },
          { key: "baz", value: [1, "string", 0.5].to_s },
          { key: "params", value: { foo: "bar" }.to_json },
        ],
      )

      travel_to(Time.utc(1999, 12, 31, 23, 59, 59)) do
        subject.trigger(:reticulated_splines,
                        foo: "Bar",
                        pi: 3.14,
                        baz: [1, "string", 0.5],
                        params: { foo: "bar" })
      end
    end
  end
end
