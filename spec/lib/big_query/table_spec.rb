require "rails_helper"
require "big_query/table"

RSpec.describe BigQuery::Table do
  subject(:table) { described_class.new("dsi_users", schema: schema, dataset: dataset) }

  let(:schema) { ->(load_schema) { load_schema.string("email", mode: :nullable) } }
  let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset, load: nil) }

  describe "#replace" do
    let(:loaded_rows) { [] }
    let(:load_schema) { instance_spy(Google::Cloud::Bigquery::LoadJob::Updater) }

    before do
      allow(dataset).to receive(:load) do |_name, file, **, &block|
        loaded_rows.concat(file.read.each_line.map { |line| JSON.parse(line, symbolize_names: true) })
        block.call(load_schema)
      end
    end

    it "replaces the table's contents in one load, creating it if needed" do
      table.replace([
        { user_id: "1", school_urn: 100_001, email: "one@contoso.com" },
        { user_id: "2", school_urn: nil, email: "two@contoso.com" },
      ])

      expect(loaded_rows).to eq([
        { user_id: "1", school_urn: 100_001, email: "one@contoso.com" },
        { user_id: "2", school_urn: nil, email: "two@contoso.com" },
      ])
      expect(dataset).to have_received(:load).once
        .with("dsi_users", anything, hash_including(format: "json", write: "truncate", create: "needed"))
    end

    it "defines the columns with the table's schema" do
      table.replace([{ user_id: "1", school_urn: 100_001, email: "one@contoso.com" }])

      expect(load_schema).to have_received(:string).with("email", mode: :nullable)
    end

    it "raises rather than emptying the table when there are no rows" do
      expect { table.replace([]) }.to raise_error(ArgumentError, "refusing to replace dsi_users with no rows")
      expect(dataset).not_to have_received(:load)
    end
  end
end
