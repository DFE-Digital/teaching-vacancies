namespace :tables_as_csv do
  desc 'Exports CSV table data into Big Query tables'
  namespace :to_big_query do
    task export: :environment do
      ExportTablesToCloudStorageJob.perform_later
      ImportCSVToBigQueryJob.perform_later
    end
  end
end
