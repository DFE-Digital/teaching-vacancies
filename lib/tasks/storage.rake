namespace :google_drive do
  desc "Remove leftover old documents on Google Drive"
  task remove_old_docs: [:environment] do
    drive_service = Google::Apis::DriveV3::DriveService.new

    next_page = nil
    count = 0

    loop do
      result = drive_service.list_files(page_token: next_page)

      result.files.each do |file|
        # Avoid deleting files in the middle of a virus check
        next if file.name.starts_with?("virus-check-")

        puts "Deleting #{file.name}"
        drive_service.delete_file(file.id)

        count += 1
      end

      next_page = result.next_page_token
      break unless next_page
    end

    quota = drive_service.get_about(fields: "storage_quota").storage_quota
    remaining = (quota.limit - quota.usage)
    human_remaining = ActiveSupport::NumberHelper.number_to_human_size(remaining)

    puts "Deleted #{count} legacy documents."
    puts "There is now #{human_remaining} of free space."
    puts "☀ Have a nice day!"
  end
end
