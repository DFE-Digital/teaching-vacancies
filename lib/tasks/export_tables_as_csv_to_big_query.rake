require 'import_csv_to_big_query'
require 'rollbar'

namespace :tables_as_csv do
  desc 'Exports CSV table data into Big Query tables'
  namespace :to_big_query do
    task export: :environment do
      Rollbar.log(:info, 'Started exporting tables to CloudStorage')
      ExportTablesToCloudStorage.new.run!
      Rollbar.log(:info, 'Started importing table to BigQuery')
      ImportCSVToBigQuery.new.load
    end
  end
end
