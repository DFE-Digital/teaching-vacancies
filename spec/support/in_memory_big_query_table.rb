# Stands in for a BigQuery::Table in specs: the same #key, #rows, #delete and #insert, held in
# memory, plus every row deleted and inserted so specs can check exactly what was written.
class InMemoryBigQueryTable
  attr_reader :key, :rows, :deleted, :inserted

  def initialize(key:, rows: [])
    @key = key
    @rows = rows
    @deleted = []
    @inserted = []
  end

  def delete(rows_to_delete)
    keys = rows_to_delete.map { |row| row_key(row) }
    removed, @rows = @rows.partition { |row| keys.include?(row_key(row)) }
    @deleted.concat(removed)
  end

  def insert(rows_to_insert)
    @rows += rows_to_insert
    @inserted.concat(rows_to_insert)
  end

  private

  def row_key(row)
    key.map { |column| row.fetch(column) }
  end
end
