require "google/apis/drive_v3"
require "google_api_client"

# Checks an uploaded file for viruses by uploading to Google Drive and attempting to download it
# again (then deleting it).
# TODO: This is a short term solution to replicate previous behaviour now that we have moved to S3
class Publishers::DocumentVirusCheck
  FILE_VIRUS_STATUS_CODE = 403 # 403 Permission denied when acknowledge_abuse: false

  def initialize(file)
    @api_client = GoogleApiClient.instance
    return unless api_client.authorization

    drive_service.authorization = api_client.authorization
    @file = file
  end

  def safe?
    return false unless drive_service

    drive_service.get_file(
      uploaded_file.id,
      acknowledge_abuse: false,
      download_dest: Rails.root.join("tmp", uploaded_file.id.to_s).to_s,
    )

    true
  rescue Google::Apis::ClientError => e
    return false if e.status_code == FILE_VIRUS_STATUS_CODE

    raise e
  ensure
    if drive_service
      FileUtils.rm_rf(Rails.root.join("tmp", uploaded_file.id.to_s).to_s)
      drive_service.delete_file(uploaded_file.id)
    end
  end

  private

  attr_reader :file, :api_client

  def uploaded_file
    @uploaded_file ||= drive_service.create_file(
      { alt: "media", name: "virus-check-#{Time.zone.now.strftime('%F-%H.%M.%S.%3N')}" },
      fields: "id, web_view_link, web_content_link, mime_type",
      upload_source: file.path,
    )
  end

  def drive_service
    return unless api_client.authorization

    @drive_service ||= Google::Apis::DriveV3::DriveService.new
  end
end
