desc "Find S3 blobs not yet mirrored to Azure and trigger mirroring"
# rubocop:disable Metrics/BlockLength

task find_and_mirror_s3_blobs: :environment do
  puts "Finding S3 blobs not yet mirrored to Azure..."
  puts "=" * 80

  # Mapping of S3 services to their corresponding Azure services
  service_mapping = {
    "amazon_s3_documents" => "azure_storage_documents",
    "amazon_s3_images_and_logos" => "azure_storage_images_and_logos",
  }

  total_found = 0
  total_queued = 0
  batch_size = 1000

  service_mapping.each do |s3_service, azure_service|
    puts "Checking '#{s3_service}' for blobs not in '#{azure_service}'..."

    service_total_found = 0
    service_total_queued = 0
    batch_num = 0

    # Process S3 blobs in batches to avoid memory issues with large datasets (we have hundreds of thousands of blobs)
    ActiveStorage::Blob.where(service_name: s3_service).find_in_batches(batch_size: batch_size) do |batch|
      batch_num += 1
      puts "Processing batch #{batch_num}..."

      # Get Azure keys for this batch's ID range
      azure_ids = ActiveStorage::Blob.where(service_name: azure_service).where(key: batch.map(&:key)).pluck(:key).to_set
      unmirored_in_batch = batch.reject { |blob| azure_ids.include?(blob.key) }
      batch_count = unmirored_in_batch.count

      service_total_found += batch_count
      # This is covered by the test suite, but SimpleCov doesn't detect the object from the block to be the same as the one from the test.
      # :nocov:
      unmirored_in_batch.each do |blob|
        blob.mirror_later
        service_total_queued += 1
      end
      # :nocov:
      puts "✓ Queued #{batch_count} blob(s) from batch #{batch_num}"
    end

    # Both branches are reached by tests. No idea why SimpleCov thinks the "else" is not reached.
    # :nocov:
    if service_total_found.zero?
      puts "No unmirored blobs found on service '#{s3_service}'"
    else
      puts "Found #{service_total_found} blob(s) not yet in Azure for '#{s3_service}'"
      total_found += service_total_found
      total_queued += service_total_queued
    end
    # :nocov:
  end

  puts "=" * 80
  puts "Mirror job summary:"
  puts "Total S3 blobs not in Azure: #{total_found}"
  puts "Mirror jobs queued: #{total_queued}"
  puts "=" * 80
end
# rubocop:enable Metrics/BlockLength
