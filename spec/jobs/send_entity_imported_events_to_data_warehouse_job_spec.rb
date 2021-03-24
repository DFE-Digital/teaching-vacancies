require "rails_helper"

RSpec.describe SendEntityImportedEventsToDataWarehouseJob do
  let!(:jobseeker) { create(:jobseeker) }
  let!(:publisher) { create(:publisher) }
  let(:big_query) { double("Bigquery") }
  let(:dataset) { double("Dataset") }
  let(:table) { double("Table") }

  before do
    allow(ENV).to receive(:fetch).with("BIG_QUERY_DATASET").and_return("test_dataset")
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(big_query)
    allow(ApplicationRecord).to receive(:descendants).and_return([Jobseeker, Publisher])
  end

  describe "#perform" do
    it "sends data to big query" do
      expect(big_query).to receive(:dataset).with("test_dataset", skip_lookup: true).and_return(dataset)
      expect(dataset).to receive(:table).with("events", skip_lookup: true).and_return(table)
      expect(table).to receive(:insert)
        .with([hash_including(type: :entity_imported, data: array_including({ key: "table_name", value: "jobseekers" }))])
      expect(table).to receive(:insert)
        .with([hash_including(type: :entity_imported, data: array_including({ key: "table_name", value: "publishers" }))])

      subject.perform
    end
  end
end
