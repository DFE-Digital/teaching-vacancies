require 'export_tables_to_big_query'

class ExportTablesToBigQueryJob < ApplicationJob
  queue_as :export_tables

  def perform
    # 2020-02-28 disabled temporarily while I work out why it ate all the disk space on a container.
    # ExportTablesToBigQuery.new.run!
  end
end
