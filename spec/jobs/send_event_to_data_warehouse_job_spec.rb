require "rails_helper"

RSpec.describe SendEventToDataWarehouseJob do
  let(:big_query) { double("Bigquery") }
  let(:dataset) { double("Dataset") }
  let(:table) { double("Table") }

  before do
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(big_query)
  end

  describe "#perform" do
    it "inserts the data into the BigQuery table" do
      expect(big_query).to receive(:dataset).with("test_dataset", skip_lookup: true).and_return(dataset)
      expect(dataset).to receive(:table).with("a_fancy_table", skip_lookup: true).and_return(table)
      expect(table).to receive(:insert).with(hash_including(foo: "bar"))

      subject.perform("a_fancy_table", { foo: "bar" })
    end
  end
end
