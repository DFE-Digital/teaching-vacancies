namespace :tables_as_csv do
  desc 'Exports postgres tables to Big Query'
  namespace :to_big_query do
    task export: :environment do
      # It doesn't use CSV anymore, but I'm not changing the task name for now to avoid having to change more of the
      # infrasctructure than strictly necessary
      ExportTablesToBigQueryJob.perform_later
    end
  end
end
