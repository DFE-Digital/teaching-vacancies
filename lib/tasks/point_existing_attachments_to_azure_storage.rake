desc "Point existing attachments from mirror services to Azure storage directly"

task point_existing_attachments_to_azure_storage: :environment do
  puts "Starting migration of attachments to Azure storage..."
  puts "=" * 80

  # Migration mapping: from mirror services to direct Azure services
  # This bypasses the mirror service (which has S3 as primary) and points directly to Azure
  migrations = {
    "mirror_documents" => "azure_storage_documents",
    "mirror_images_and_logos" => "azure_storage_images_and_logos",
  }

  total_updated = 0

  migrations.each do |old_service, new_service|
    puts "\nMigrating blobs from '#{old_service}' to '#{new_service}'..."

    blobs = ActiveStorage::Blob.where(service_name: old_service)
    count = blobs.count

    if count.zero?
      puts "No blobs found for service '#{old_service}'"
    else
      puts "Found #{count} blob(s) to migrate"
      # Update service names in batches
      updated_count = blobs.update_all(service_name: new_service)
      total_updated += updated_count
      puts "✓ Updated #{updated_count} blob(s) to use '#{new_service}'"
    end
  end

  puts "\n#{'=' * 80}"
  puts "Migration complete!"
  puts "Total blobs updated: #{total_updated}"
  puts "=" * 80
end
