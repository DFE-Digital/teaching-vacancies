module BigQuery
  # Syncs an Enumerable of rows into a table, so its contents end up matching the source. Rows
  # are matched on the table's `key` columns: rows only in the source are inserted, rows only
  # in the table are deleted, and rows in both are replaced only if their values differ. An
  # empty source empties the table.
  #
  # Rows are compared with ==, so the source must send each value as the table reads it back
  # (a Time for a TIMESTAMP, an Integer for an INTEGER).
  #
  # The table is a BigQuery::Table in production, or anything with the same #key, #rows,
  # #delete and #insert. A changed row is replaced by deleting it and inserting it again,
  # because that is what BigQuery can do in bulk. The two steps are not atomic, so if the
  # insert fails the changed rows are missing until the next sync puts them back.
  module TableSync
    Diff = Data.define(:inserted, :updated, :deleted, :unchanged)

    class << self
      def call(table:, rows:)
        changes = diff(source: rows, table: table.rows, key: table.key)

        table.delete(changes.deleted + changes.updated)
        table.insert(changes.inserted + changes.updated)
      end

      # Updated rows come back with the source's values; deleted and unchanged rows as the
      # table holds them.
      def diff(source:, table:, key:)
        existing = table.index_by { |row| row_key(row, key) }
        inserted = []
        updated = []
        unchanged = []

        source.index_by { |row| row_key(row, key) }.each do |row_key, row|
          stored = existing.delete(row_key)

          if stored.nil?
            inserted << row
          elsif stored == row
            unchanged << stored
          else
            updated << row
          end
        end

        Diff.new(inserted:, updated:, deleted: existing.values, unchanged:)
      end

      private

      def row_key(row, key)
        key.map { |column| row.fetch(column) }
      end
    end
  end
end
