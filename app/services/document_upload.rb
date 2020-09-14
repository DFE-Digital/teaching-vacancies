require 'google/apis/drive_v3'

class DocumentUpload
  FILE_VIRUS_STATUS_CODE = 403 # 403 Permission denied when acknowledge_abuse: false

  class MissingUploadPath < StandardError; end
  attr_accessor :drive_service, :upload_path, :name, :uploaded, :safe_download, :google_error, :download_path

  def initialize(opts = {})
    raise MissingUploadPath if opts[:upload_path].nil?

    self.upload_path = opts[:upload_path]
    self.name = opts[:name]
    self.drive_service = Google::Apis::DriveV3::DriveService.new
    self.safe_download = true
    self.google_error = false
  end

  def upload
    upload_hiring_staff_document
    set_public_permission_on_document
  rescue Google::Apis::Error
    self.google_error = true
  else
    google_drive_virus_check
  end

  def upload_hiring_staff_document
    self.uploaded = drive_service.create_file(
      { alt: 'media', name: name },
      fields: 'id, web_view_link, web_content_link, mime_type',
      upload_source: upload_path,
    )
  end

  def set_public_permission_on_document
    drive_service.create_permission(
      uploaded.id,
      Google::Apis::DriveV3::Permission.new(type: 'anyone', role: 'reader'),
    )
  end

  def google_drive_virus_check
    self.download_path = uploaded.id.to_s
    drive_service.get_file(
      uploaded.id,
      acknowledge_abuse: false,
      download_dest: download_path,
    )
  rescue Google::Apis::ClientError => e
    if e.status_code == FILE_VIRUS_STATUS_CODE
      self.safe_download = false
      drive_service.delete_file(uploaded.id)
      Rollbar.log(:info, 'Google drive detected the upload of a malicious file. This file has been deleted.')
    else
      self.google_error = true
    end
  ensure
    File.delete(download_path) if File.exist?(download_path)
  end
end
