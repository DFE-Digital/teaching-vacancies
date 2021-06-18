namespace :google_drive do
  desc "Enqueue existing documents for migration to Active Storage"
  task migrate_to_active_storage: [:environment] do
    vacancies = Vacancy.includes(:documents).distinct.where.not(documents: { id: nil })
    puts "Enqueueing #{vacancies.count} vacancies with documents for migration to Active Storage"

    vacancies.pluck(:id).each do |vacancy_id|
      MigrateVacancyDocumentsToActiveStorageJob.perform_later(vacancy_id)
    end

    puts "⛅ Have a nice day!"
  end

  desc "Verify Google Drive migration was successful"
  task :verify_migration, [:retry] => [:environment] do |_task, args|
    Rails.logger.silence do
      vacancies_with_documents = Vacancy.includes(:documents).distinct.where.not(documents: { id: nil })
      total_count = vacancies_with_documents.count
      matching_count = 0
      mismatching_count = 0

      puts "Checking #{total_count} vacancies with existing documents..."

      vacancies_with_documents.with_attached_supporting_documents.find_each do |vacancy|
        docs = vacancy.documents.map { |d| [d.name, d.size] }.sort
        supporting_docs = vacancy.supporting_documents.map { |sd| [sd.filename.to_s, sd.byte_size] }.sort

        if docs == supporting_docs
          puts "✅ Vacancy #{vacancy.id} has matching documents and supporting documents"
          matching_count += 1
        else
          puts "❌ Mismatch between documents and supporting documents for Vacancy #{vacancy.id}"
          puts "Documents:"
          pp docs
          puts "Supporting documents:"
          pp supporting_docs
          puts
          mismatching_count += 1

          if args[:retry] == "retry"
            puts "🔁 Enqueueing a job to try again"
            MigrateVacancyDocumentsToActiveStorageJob.perform_later(vacancy.id)
          end
        end
      end

      puts "Found #{matching_count} vacancies with matching docs, and #{mismatching_count} problematic ones."
      puts "Have a nice day!"
    end
  end

  desc "Delete old documents"
  task :delete_old_documents, [:commit] => [:environment] do |_task, args|
    delete_before = Date.new(2021, 2, 1)

    documents = Document.includes(:vacancy).where("documents.created_at <?", delete_before)

    puts "Found #{documents.count} documents to delete that were created before #{delete_before}"

    next unless args[:commit] == "true"

    puts "Get ready to delete them!"
    documents_deleted = 0

    documents.find_each do |document|
      vacancy = document.vacancy
      if vacancy.published? && vacancy.expires_at.future?
        puts "NOT deleting document name:#{document.name} size:#{document.size} from published vacancy #{document.vacancy.id}"
        next
      end

      puts "Deleting document name:#{document.name} size:#{document.size}"

      DocumentDelete.new(document).delete
      documents_deleted += 1

      puts "Deleted document name:#{document.name} size:#{document.size}"
    end

    puts "#{documents_deleted} Documents deleted. Have a good day!"
  end
end
