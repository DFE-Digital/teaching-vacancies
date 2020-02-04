namespace :database_records do
  desc 'Updates Big Query Datasets with latest database records'
  namespace :in_big_query do
    task update: :environment do
      ExportVacancyRecordsToBigQueryJob.perform_later
      ExportUserRecordsToBigQueryJob.perform_later
    end
  end
end
