namespace :google_drive do
  desc "Migrate existing documents to S3"
  task :migrate_to_s3, [:commit] => [:environment] do |_task, args|
    Rails.logger.silence do
      puts "Migrating #{Document.count} documents to S3"

      total_count = Document.count
      skipped_count = 0
      migrated_count = 0

      Document.includes(:vacancy).find_each(batch_size: 100).with_index do |doc, index|
        puts "• #{doc.id}: #{doc.name} (#{index + 1}/#{total_count})"
        puts "  ├ Vacancy #{doc.vacancy.id} ('#{doc.vacancy.job_title}')"

        if doc.vacancy.supporting_documents.any? { |supporting_doc| supporting_doc.blob.filename == doc.name }
          puts "  └ ⏭ Skipping because it already exists in ActiveStorage"

          skipped_count += 1
          next
        end

        if args[:commit] == "true"
          puts "  ├ Downloading from GDrive at #{doc.download_url}..."
          doc.vacancy.supporting_documents.attach(
            io: URI.parse(doc.download_url).open,
            filename: doc.name,
            content_type: doc.content_type,
          )
          puts "  └ ✅ Migrated!"
        else
          puts "  └ ℹ Would migrate document from #{doc.download_url}"
        end

        migrated_count += 1
      end

      total_attachments = ActiveRecord::Base.connection.select_value("SELECT COUNT(*) FROM active_storage_attachments")

      puts
      puts "📊 Migrated #{migrated_count} documents and skipped #{skipped_count} documents."
      puts "🤔 We now have #{total_attachments} ActiveStorage attachments, and #{total_count} legacy documents."
      puts "⛅ Have a nice day!"
    end
  end

  desc "Delete old documents"
  task :delete_old_documents, [:commit] => [:environment] do |_task, args|
    delete_before = Date.new(2020, 12, 15)

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
