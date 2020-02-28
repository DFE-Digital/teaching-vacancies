namespace :database_records do
  desc 'Updates Big Query user and approver tables with latest records from DSI'
  namespace :in_big_query do
    task update: :environment do
      ExportDsiUsersToBigQueryJob.perform_later
    end
  end
end
