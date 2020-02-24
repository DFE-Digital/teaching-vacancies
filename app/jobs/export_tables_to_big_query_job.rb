require 'export_tables_to_big_query'

class ExportTablesToBigQueryJob < ApplicationJob
  queue_as :export_tables

  def perform
    ExportTablesToBigQuery.new.run!
  end
end
