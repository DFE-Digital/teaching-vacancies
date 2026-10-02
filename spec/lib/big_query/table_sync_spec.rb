require "rails_helper"
require "big_query/table_sync"

RSpec.describe BigQuery::TableSync do
  let(:dataset) { instance_double(Google::Cloud::Bigquery::Dataset) }
  let(:project) { instance_double(Google::Cloud::Bigquery::Project, dataset: dataset) }

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

  let(:key) { %i[user_id] }
  let(:deleted_rows) { [] }
  let(:loaded_rows) { [] }

  let(:select_sql) { "SELECT TO_JSON_STRING([CAST(user_id AS STRING)]) AS row_key, * FROM `dsi_users`" }
  let(:delete_sql) { "DELETE FROM `dsi_users` WHERE TO_JSON_STRING([CAST(user_id AS STRING)]) IN UNNEST(@row_keys)" }

  # Stands in for the BigQuery table, applying the SELECT, DELETE and append load that
  # TableSync sends. Keys are built the way TO_JSON_STRING([CAST(<key> AS STRING), ...]) would.
  before do
    allow(Google::Cloud::Bigquery).to receive(:new).and_return(project)

    allow(dataset).to receive(:query).with(select_sql) do
      instance_double(Google::Cloud::Bigquery::Data, all: table_rows.map { |row| row.merge(row_key: bigquery_key(row)) })
    end

    allow(dataset).to receive(:query).with(delete_sql, params: { row_keys: anything }) do |_sql, params:|
      removed, kept = table_rows.partition { |row| params[:row_keys].include?(bigquery_key(row)) }
      deleted_rows.concat(removed)
      table_rows.replace(kept)
    end

    allow(dataset).to receive(:load) do |_table, file, **|
      rows = file.read.each_line.map { |line| JSON.parse(line, symbolize_names: true) }
      loaded_rows.concat(rows)
      table_rows.concat(rows)
    end
  end

  def sync(rows = api_rows)
    described_class.call(table: "dsi_users", key: key, rows: rows.each)
  end

  def bigquery_key(row)
    key.map { |column| row[column]&.to_s }.to_json
  end

  it "adds new rows, replaces changed rows and removes rows no longer in the source" do
    sync

    expect(table_rows).to contain_exactly(
      { user_id: "1", email: "one@contoso.com" },
      { user_id: "2", email: "two-updated@contoso.com" },
      { user_id: "3", email: "three@contoso.com" },
    )
  end

  it "deletes the removed and changed rows, leaving unchanged rows in place" do
    sync

    expect(deleted_rows).to contain_exactly(
      { user_id: "2", email: "two@contoso.com" },
      { user_id: "4", email: "four@contoso.com" },
    )
  end

  it "loads the added and changed rows, not the unchanged ones" do
    sync

    expect(loaded_rows).to contain_exactly(
      { user_id: "2", email: "two-updated@contoso.com" },
      { user_id: "3", email: "three@contoso.com" },
    )
  end

  context "when nothing has changed" do
    let(:api_rows) { table_rows.map(&:dup) }

    it "neither deletes nor loads any rows" do
      sync

      expect(deleted_rows).to eq([])
      expect(loaded_rows).to eq([])
    end
  end

  context "when a row has only been removed from the source" do
    let(:api_rows) do
      [
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two@contoso.com" },
      ]
    end

    it "deletes just that row and loads nothing" do
      sync

      expect(deleted_rows).to eq([{ user_id: "4", email: "four@contoso.com" }])
      expect(loaded_rows).to eq([])
      expect(table_rows).to contain_exactly(
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two@contoso.com" },
      )
    end
  end

  context "when a row has only changed in the source" do
    let(:api_rows) do
      [
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two-updated@contoso.com" },
        { user_id: "4", email: "four@contoso.com" },
      ]
    end

    it "deletes and reloads just that row" do
      sync

      expect(deleted_rows).to eq([{ user_id: "2", email: "two@contoso.com" }])
      expect(loaded_rows).to eq([{ user_id: "2", email: "two-updated@contoso.com" }])
      expect(table_rows).to contain_exactly(
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two-updated@contoso.com" },
        { user_id: "4", email: "four@contoso.com" },
      )
    end
  end

  context "when a row has only been added to the source" do
    let(:api_rows) do
      [
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two@contoso.com" },
        { user_id: "3", email: "three@contoso.com" },
        { user_id: "4", email: "four@contoso.com" },
      ]
    end

    it "loads just that row and deletes nothing" do
      sync

      expect(deleted_rows).to eq([])
      expect(loaded_rows).to eq([{ user_id: "3", email: "three@contoso.com" }])
      expect(table_rows).to contain_exactly(
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two@contoso.com" },
        { user_id: "3", email: "three@contoso.com" },
        { user_id: "4", email: "four@contoso.com" },
      )
    end
  end

  context "when BigQuery holds a timestamp the source sent as an ISO 8601 string" do
    let(:api_rows) { [{ user_id: "1", update_datetime: "2026-09-01T10:15:00Z" }] }
    let(:table_rows) { [{ user_id: "1", update_datetime: Time.utc(2026, 9, 1, 10, 15) }] }

    it "treats the row as unchanged" do
      sync

      expect(table_rows).to eq([{ user_id: "1", update_datetime: Time.utc(2026, 9, 1, 10, 15) }])
      expect(deleted_rows).to eq([])
      expect(loaded_rows).to eq([])
    end

    context "when the timestamp has changed" do
      let(:api_rows) { [{ user_id: "1", update_datetime: "2026-09-02T10:15:00Z" }] }

      it "replaces the row" do
        sync

        expect(table_rows).to eq([{ user_id: "1", update_datetime: "2026-09-02T10:15:00Z" }])
      end
    end
  end
end
