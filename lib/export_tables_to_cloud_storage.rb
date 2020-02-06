require 'google/cloud/storage'
require 'fileutils'

class ExportTablesToCloudStorage
  TABLES = %w[
      Vacancy
      AlertRun
      AuditData
      DetailedSchoolType
      GeneralFeedback
      Leadership
      PayScale
      Region
      School
      SchoolType
      Subject
      Subscription
      TransactionAuditor
      User
      VacancyPublishFeedback
  ]

  BATCH_SIZE = 1000

  attr_reader :bucket

  def initialize(storage: Google::Cloud::Storage.new)
    @bucket = storage.bucket ENV.fetch('CLOUD_STORAGE_BUCKET')
  end

  def run!
    export_csv_files
    upload_to_google_cloud_storage
    remove_csv_folder
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Rails/Date
  def export_csv_files
    Dir.mkdir(Rails.root.join('tmp/csv_export')) unless File.exist?(Rails.root.join('tmp/csv_export'))

    TABLES.each do |table|
      file = Rails.root.join("tmp/csv_export/#{table.underscore}.csv")
      table == 'Vacancy' ? records = vacancy_records_with_removed_fields : records = table.constantize.all

      next unless records.any?

      CSV.open(file, 'w') do |csv|
        csv << records.first.attributes.keys
        records.find_in_batches batch_size: BATCH_SIZE do |batch|
          batch.each do |row|
            row_values = row.attributes.values
            row_values.each_with_index do |value, index|
                if value.to_time != nil
                  row_values[index] = value.to_time.strftime('%F %T')
                end
              rescue ArgumentError
                nil
              rescue NoMethodError
                nil
            end
            csv << row_values
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Rails/Date

  def upload_to_google_cloud_storage
    Dir.children('tmp/csv_export').each do |csv_file|
      local_file_path   = "tmp/csv_export/#{csv_file}"
      storage_file_path = "csv_export/#{csv_file}"
      bucket.create_file local_file_path, storage_file_path
    end
  end

  def remove_csv_folder
    FileUtils.rm_rf(Rails.root.join('tmp/csv_export'))
  end

  def vacancy_records_with_removed_fields
    Vacancy.select(Vacancy.column_names - ['job_description', 'weekly_hours'].map(&:to_s))
  end
end
