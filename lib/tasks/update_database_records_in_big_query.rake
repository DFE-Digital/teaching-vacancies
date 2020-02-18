namespace :database_records do
  desc 'Updates Big Query User records Dataset with latest records from DSI'
  namespace :in_big_query do
    task update: :environment do
      ExportUserRecordsToBigQueryJob.perform_later
    end
  end
end
