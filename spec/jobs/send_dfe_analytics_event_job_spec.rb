require "rails_helper"

RSpec.describe SendDfeAnalyticsEventJob do
  let(:event_details) do
    {
      type: "Page Visited",
      request: {},
      response: {},
      data: {},
    }
  end

  let(:event) { double("Event") }

  before do
    allow(DfE::Analytics::Event).to receive(:new).and_return(event)
    allow(event).to receive(:with_type).with("Page Visited").and_return(event)
    allow(event).to receive(:with_request_details).with({}).and_return(event)
    allow(event).to receive(:with_response_details).with({}).and_return(event)
    allow(event).to receive(:with_data).with({}).and_return(event)
  end

  describe "#perform" do
    it "inserts the data into the BigQuery table" do
      expect(DfE::Analytics::SendEvents).to receive(:do).with([event])

      subject.perform(event_details)
    end
  end
end
