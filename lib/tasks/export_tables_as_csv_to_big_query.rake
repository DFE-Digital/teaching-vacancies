require 'import_csv_to_big_query'

namespace :tables_as_csv do
  desc 'Exports CSV table data into Big Query tables'
  namespace :to_big_query do
    task export: :environment do
      ExportTablesToCloudStorage.new.run!
      ImportCSVToBigQuery.new.load
    end
  end
end
