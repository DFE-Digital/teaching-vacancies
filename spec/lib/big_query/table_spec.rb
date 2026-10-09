require "rails_helper"
require "big_query/table"

RSpec.describe BigQuery::Table do
  subject(:table) { described_class.new("dsi_users", key: %i[user_id school_urn], schema: schema, dataset: dataset) }

  let(:schema) { ->(load_schema) { load_schema.string("email", mode: :nullable) } }
  let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset, table: bigquery_table, query: nil, load: nil) }
  let(:bigquery_table) { instance_double(Google::Cloud::Bigquery::Table, data: table_data) }
  let(:table_data) { instance_double(Google::Cloud::Bigquery::Data, all: stored_rows.each) }
  let(:stored_rows) { [] }

  describe "#rows" do
    let(:stored_rows) do
      [
        { user_id: "1", school_urn: 100_001, email: "one@contoso.com" },
        { user_id: "2", school_urn: nil, email: "two@contoso.com" },
      ]
    end

    it "reads every row in the table without running a query" do
      expect(table.rows.to_a).to eq(stored_rows)
      expect(dataset).to have_received(:table).with("dsi_users")
      expect(dataset).not_to have_received(:query)
    end

    context "when the table does not exist" do
      let(:bigquery_table) { nil }

      it "has no rows" do
        expect(table.rows).to eq([])
      end
    end
  end

  describe "#delete" do
    it "deletes the rows whose key columns match, including a NULL key column" do
      table.delete([
        { user_id: "1", school_urn: "100001", email: "one@contoso.com" },
        { user_id: "2", school_urn: nil, email: "two@contoso.com" },
      ])

      expect(dataset).to have_received(:query).with(
        "DELETE FROM `dsi_users` " \
        "WHERE TO_JSON_STRING([CAST(user_id AS STRING), CAST(school_urn AS STRING)]) IN UNNEST(@row_keys)",
        params: { row_keys: ['["1","100001"]', '["2",null]'] },
      )
    end

    it "matches typed key values by their string form" do
      table.delete([{ user_id: 1, school_urn: 100_001, email: "one@contoso.com" }])

      expect(dataset).to have_received(:query).with(anything, params: { row_keys: ['["1","100001"]'] })
    end

    it "raises when a row is missing a key column, rather than deleting on a partial key" do
      expect { table.delete([{ user_id: "1", email: "one@contoso.com" }]) }.to raise_error(KeyError)
      expect(dataset).not_to have_received(:query)
    end

    it "does nothing when there are no rows to delete" do
      table.delete([])

      expect(dataset).not_to have_received(:query)
    end
  end

  describe "#insert" do
    let(:loaded_rows) { [] }
    let(:load_schema) { instance_spy(Google::Cloud::Bigquery::LoadJob::Updater) }

    before do
      allow(dataset).to receive(:load) do |_name, file, **, &block|
        loaded_rows.concat(file.read.each_line.map { |line| JSON.parse(line, symbolize_names: true) })
        block.call(load_schema)
      end
    end

    it "appends the rows to the table, creating it if needed" do
      table.insert([
        { user_id: "1", school_urn: 100_001, email: "one@contoso.com" },
        { user_id: "2", school_urn: nil, email: "two@contoso.com" },
      ])

      expect(loaded_rows).to eq([
        { user_id: "1", school_urn: 100_001, email: "one@contoso.com" },
        { user_id: "2", school_urn: nil, email: "two@contoso.com" },
      ])
      expect(dataset).to have_received(:load)
        .with("dsi_users", anything, hash_including(format: "json", write: "append", create: "needed"))
    end

    it "defines the columns with the table's schema" do
      table.insert([{ user_id: "1", school_urn: 100_001, email: "one@contoso.com" }])

      expect(load_schema).to have_received(:string).with("email", mode: :nullable)
    end

    it "does nothing when there are no rows to insert" do
      table.insert([])

      expect(dataset).not_to have_received(:load)
    end
  end
end
