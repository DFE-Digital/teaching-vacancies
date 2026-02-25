desc "Backfill Azure storage by migrating blobs to mirror services and triggering mirroring"
# rubocop:disable Metrics/BlockLength
task backfill_azure_storage: :environment do
  puts "Starting Azure storage backfill..."
  puts "=" * 80

  # We need to update the service_name for blobs using the old services to point to the new mirror services, so that
  # the mirroring service can pick them up and mirror them to Azure.
  # This is necessary because the MirrorJob looks for blobs using the mirror service names.
  migrations = {
    "amazon_s3_documents" => "mirror_documents",
    "amazon_s3_images_and_logos" => "mirror_images_and_logos",
  }

  total_updated = 0
  total_mirrored = 0

  migrations.each do |old_service, new_service|
    puts "\nMigrating blobs from '#{old_service}' to '#{new_service}'..."

    blobs = ActiveStorage::Blob.where(service_name: old_service)
    count = blobs.count

    if count.zero?
      puts "  No blobs found for service '#{old_service}'"
      next
    end

    puts "  Found #{count} blob(s) to migrate"

    # Update service names in batches
    updated_count = blobs.update_all(service_name: new_service)
    total_updated += updated_count
    puts "  ✓ Updated #{updated_count} blob(s) to use '#{new_service}'"
  end

  # Now trigger mirroring for all blobs using mirror services
  puts "\n#{'=' * 80}"
  puts "Triggering mirroring jobs..."

  mirror_services = migrations.values
  mirror_blobs = ActiveStorage::Blob.where(service_name: mirror_services)
  mirror_count = mirror_blobs.count

  puts "Found #{mirror_count} blob(s) to mirror"

  if mirror_count.positive?
    mirror_blobs.find_each do |blob|
      blob.mirror_later
      total_mirrored += 1
    end

    puts "  ✓ Queued #{total_mirrored} blob(s) for mirroring"
  end

  puts "\n#{'=' * 80}"
  puts "Backfill complete!"
  puts "  Service names updated: #{total_updated}"
  puts "  Mirror jobs queued: #{total_mirrored}"
  puts "=" * 80
end
# rubocop:enable Metrics/BlockLength
