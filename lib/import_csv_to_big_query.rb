require "google/cloud/bigquery"

class ImportCSVToBigQuery

  def load
    bigquery = Google::Cloud::Bigquery.new
    dataset  = bigquery.dataset ENV.fetch('BIG_QUERY_DATASET')
    csv_files = ['detailed_school_type', 'leadership', 'region', 'school', 'school_type', 'vacancy']
    csv_files.each do |file|
      import_csv_uri  = "gs://tvs_staging/csv_export/#{file}.csv"
      table_id = import_csv_uri.split("/").last.sub(".csv","")

      load_job = dataset.load_job table_id, import_csv_uri, skip_leading: 1, autodetect: true, write: 'truncate'
      
      puts "Starting job #{load_job.job_id}"

      load_job.wait_until_done!  # Waits for table load to complete.
      puts "Job finished."

      table = dataset.table(table_id)
      puts "Loaded #{table.rows_count} rows to table #{table.id}"
    end
  end
end
