class ExportTablesToCSVFiles
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

  def run!
    Dir.mkdir(Rails.root.join('tmp/csv_export')) unless File.exist?(Rails.root.join('tmp/csv_export'))

    TABLES.each do |table|
      file = Rails.root.join("tmp/csv_export/#{table.downcase}.csv")
      records = table.constantize.all

      next unless records.any?

      CSV.open(file, 'w') do |csv|
        csv << records.first.attributes.keys
        records.each do |row|
          csv << row.attributes.values
        end
      end
    end
  end
end
