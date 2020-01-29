require 'import_csv_to_big_query'

class ImportCSVToBigQueryJob < ApplicationJob
  queue_as :import_csv

  def perform
    ImportCSVToBigQuery.new.load
  end
end
