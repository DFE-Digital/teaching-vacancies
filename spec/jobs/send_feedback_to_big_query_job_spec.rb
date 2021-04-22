require "rails_helper"

RSpec.describe SendFeedbackToBigQueryJob do
  let(:big_query) { double("Bigquery") }
  let(:dataset) { double("Dataset") }
  let(:table) { double("Table") }
  let!(:feedback1) { create(:feedback) }
  let!(:feedback2) { create(:feedback, comment: "A different comment") }

  before do
    allow(ENV).to receive(:fetch).with("BIG_QUERY_DATASET").and_return("test_dataset")
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(big_query)
  end

  describe "#perform" do
    it "sends data to big query" do
      expect(big_query).to receive(:dataset).with("test_dataset", skip_lookup: true).and_return(dataset)
      expect(dataset).to receive(:table).with("feedbacks", skip_lookup: true).and_return(table)
      expect(table).to receive(:insert)
        .with([
          hash_including(
            type: feedback1.feedback_type,
            occurred_at: feedback1.created_at,
            data: array_including(
              hash_including(key: "visit_purpose", value: "find_teaching_job"),
              hash_including(key: "comment", value: "Some feedback text"),
            ),
          ),
          hash_including(
            type: feedback2.feedback_type,
            occurred_at: feedback2.created_at,
            data: array_including(
              hash_including(key: "visit_purpose", value: "find_teaching_job"),
              hash_including(key: "comment", value: "A different comment"),
            ),
          ),
        ])

      subject.perform
    end
  end
end
