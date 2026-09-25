require "rails_helper"
require "big_query/table_sync"

RSpec.describe BigQuery::TableSync do
  let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset) }
  let(:bigquery_table) { instance_double(Google::Cloud::Bigquery::Table) }

  let(:api_rows) do
    [
      { user_id: "1", email: "one@contoso.com" },
      { user_id: "2", email: "two-updated@contoso.com" },
      { user_id: "3", email: "three@contoso.com" },
    ]
  end

  let(:table_rows) do
    [
      { user_id: "1", email: "one@contoso.com" },
      { user_id: "2", email: "two@contoso.com" },
      { user_id: "4", email: "four@contoso.com" },
    ]
  end

  # Stands in for the BigQuery table, applying the SELECT, DELETE and append load that TableSync sends.
  before do
    allow(dataset).to receive(:table).with("dsi_users").and_return(bigquery_table)

    allow(dataset).to receive(:query) do |sql, params: {}|
      if sql.start_with?("DELETE")
        table_rows.reject! { |row| params[:row_keys].include?([row[:user_id]].to_json) }
      end
      instance_double(Google::Cloud::Bigquery::Data, all: table_rows.dup)
    end

    allow(dataset).to receive(:load) do |_table, file, write:, **|
      expect(write).to eq("append")
      table_rows.concat(file.read.each_line.map { |line| JSON.parse(line, symbolize_names: true) })
    end
  end

  def sync(rows = api_rows)
    described_class.call(dataset: dataset, table: "dsi_users", key: %i[user_id], rows: rows.each)
  end

  it "adds rows that are in the source but not the table" do
    sync

    expect(table_rows).to include({ user_id: "3", email: "three@contoso.com" })
  end

  it "updates rows that have changed in the source" do
    sync

    expect(table_rows).to include({ user_id: "2", email: "two-updated@contoso.com" })
    expect(table_rows).not_to include({ user_id: "2", email: "two@contoso.com" })
  end

  it "removes rows that are no longer in the source" do
    sync

    expect(table_rows.pluck(:user_id)).not_to include("4")
  end

  it "leaves the table matching the source" do
    sync

    expect(table_rows).to match_array(api_rows)
  end

  it "leaves unchanged rows alone" do
    sync

    expect(dataset).to have_received(:query)
      .with(start_with("DELETE"), params: { row_keys: match_array([%w[4].to_json, %w[2].to_json]) })
  end

  it "does nothing when the table already matches the source" do
    sync(table_rows.dup)

    expect(dataset).not_to have_received(:query).with(start_with("DELETE"), anything)
    expect(dataset).not_to have_received(:load)
  end

  it "refuses to sync an empty source, so a blank API response can't wipe the table" do
    expect { sync([]) }.to raise_error(BigQuery::TableSync::EmptySourceError)
    expect(dataset).not_to have_received(:query)
  end
end
