require "google/apis/drive_v3"

# Checks an uploaded file for viruses by uploading to Google Drive and attempting to download it
# again (then deleting it).
# TODO: This is a short term solution to replicate previous behaviour now that we have moved to S3
class Publishers::DocumentVirusCheck
  FILE_VIRUS_STATUS_CODE = 403 # 403 Permission denied when acknowledge_abuse: false

  def initialize(file)
    @file = file
  end

  def safe?
    drive_service.get_file(
      uploaded_file.id,
      acknowledge_abuse: false,
      download_dest: uploaded_file.id.to_s,
    )
    true
  rescue Google::Apis::ClientError => e
    return false if e.status_code == FILE_VIRUS_STATUS_CODE

    raise e
  ensure
    FileUtils.rm_rf(uploaded_file.id.to_s)
    drive_service.delete_file(uploaded_file.id)
  end

  private

  attr_reader :file

  def uploaded_file
    @uploaded_file ||= drive_service.create_file(
      { alt: "media", name: "virus-check-#{Time.zone.now.strftime('%F-%H.%M.%S.%3N')}" },
      fields: "id, web_view_link, web_content_link, mime_type",
      upload_source: file.path,
    )
  end

  def drive_service
    @drive_service ||= Google::Apis::DriveV3::DriveService.new
  end
end
