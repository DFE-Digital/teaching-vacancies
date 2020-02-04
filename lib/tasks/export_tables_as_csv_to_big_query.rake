require 'import_csv_to_big_query'
require 'rollbar'

namespace :tables_as_csv do
  desc 'Exports CSV table data into Big Query tables'
  namespace :to_big_query do
    task export: :environment do
      ImportCSVToBigQueryJob.perform_later
    end
  end
end
