require "rails_helper"
require "big_query/table_sync"

RSpec.describe BigQuery::TableSync do
  describe ".diff" do
    subject(:diff) { described_class.diff(source: source, table: table, key: key) }

    let(:key) { %i[user_id] }

    let(:source) do
      [
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two-updated@contoso.com" },
        { user_id: "3", email: "three@contoso.com" },
      ]
    end

    let(:table) do
      [
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two@contoso.com" },
        { user_id: "4", email: "four@contoso.com" },
      ]
    end

    it "inserts the rows that are only in the source" do
      expect(diff.inserted).to eq([{ user_id: "3", email: "three@contoso.com" }])
    end

    it "updates the rows whose values have changed, using the source's values" do
      expect(diff.updated).to eq([{ user_id: "2", email: "two-updated@contoso.com" }])
    end

    it "deletes the rows that are no longer in the source" do
      expect(diff.deleted).to eq([{ user_id: "4", email: "four@contoso.com" }])
    end

    it "leaves the rows that have not changed untouched" do
      expect(diff.unchanged).to eq([{ user_id: "1", email: "one@contoso.com" }])
    end

    context "when the source matches the table" do
      let(:source) { table.map(&:dup) }

      it "changes nothing" do
        expect(diff.inserted).to eq([])
        expect(diff.updated).to eq([])
        expect(diff.deleted).to eq([])
        expect(diff.unchanged).to contain_exactly(
          { user_id: "1", email: "one@contoso.com" },
          { user_id: "2", email: "two@contoso.com" },
          { user_id: "4", email: "four@contoso.com" },
        )
      end
    end

    context "when the table is empty" do
      let(:table) { [] }

      it "inserts every source row" do
        expect(diff.inserted).to contain_exactly(
          { user_id: "1", email: "one@contoso.com" },
          { user_id: "2", email: "two-updated@contoso.com" },
          { user_id: "3", email: "three@contoso.com" },
        )
        expect(diff.updated).to eq([])
        expect(diff.deleted).to eq([])
        expect(diff.unchanged).to eq([])
      end
    end

    context "when the source is empty" do
      let(:source) { [] }

      it "deletes every table row" do
        expect(diff.inserted).to eq([])
        expect(diff.updated).to eq([])
        expect(diff.deleted).to contain_exactly(
          { user_id: "1", email: "one@contoso.com" },
          { user_id: "2", email: "two@contoso.com" },
          { user_id: "4", email: "four@contoso.com" },
        )
        expect(diff.unchanged).to eq([])
      end
    end

    # DSI returns a user once per organisation, so a row is only identified by the whole key.
    context "with a key of more than one column" do
      let(:key) { %i[user_id school_urn] }

      let(:source) do
        [
          { user_id: "1", school_urn: "100001", email: "one@contoso.com" },
          { user_id: "1", school_urn: "100002", email: "one-updated@contoso.com" },
        ]
      end

      let(:table) do
        [
          { user_id: "1", school_urn: "100001", email: "one@contoso.com" },
          { user_id: "1", school_urn: "100002", email: "one@contoso.com" },
          { user_id: "1", school_urn: "100003", email: "one@contoso.com" },
        ]
      end

      it "matches rows on every key column" do
        expect(diff.inserted).to eq([])
        expect(diff.updated).to eq([{ user_id: "1", school_urn: "100002", email: "one-updated@contoso.com" }])
        expect(diff.deleted).to eq([{ user_id: "1", school_urn: "100003", email: "one@contoso.com" }])
        expect(diff.unchanged).to eq([{ user_id: "1", school_urn: "100001", email: "one@contoso.com" }])
      end
    end

    # The source has to send values typed as the table holds them; TableSync doesn't convert.
    context "when the source sends a value with a different type from the table's" do
      let(:source) { [{ user_id: "1", login_count: "3" }] }
      let(:table) { [{ user_id: "1", login_count: 3 }] }

      it "treats the row as changed" do
        expect(diff.updated).to eq([{ user_id: "1", login_count: "3" }])
        expect(diff.unchanged).to eq([])
      end
    end
  end

  describe ".call" do
    let(:table) do
      InMemoryBigQueryTable.new(
        key: %i[user_id],
        rows: [
          { user_id: "1", email: "one@contoso.com" },
          { user_id: "2", email: "two@contoso.com" },
          { user_id: "4", email: "four@contoso.com" },
        ],
      )
    end

    let(:source) do
      [
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two-updated@contoso.com" },
        { user_id: "3", email: "three@contoso.com" },
      ]
    end

    before { described_class.call(table: table, rows: source.each) }

    it "leaves the table holding exactly the source rows" do
      expect(table.rows).to contain_exactly(
        { user_id: "1", email: "one@contoso.com" },
        { user_id: "2", email: "two-updated@contoso.com" },
        { user_id: "3", email: "three@contoso.com" },
      )
    end

    it "deletes only the removed rows and the old versions of the changed ones" do
      expect(table.deleted).to contain_exactly(
        { user_id: "2", email: "two@contoso.com" },
        { user_id: "4", email: "four@contoso.com" },
      )
    end

    it "inserts only the new rows and the new versions of the changed ones" do
      expect(table.inserted).to contain_exactly(
        { user_id: "2", email: "two-updated@contoso.com" },
        { user_id: "3", email: "three@contoso.com" },
      )
    end

    context "when nothing has changed" do
      let(:source) { table.rows.map(&:dup) }

      it "neither deletes nor inserts any rows" do
        expect(table.deleted).to eq([])
        expect(table.inserted).to eq([])
      end
    end
  end
end
