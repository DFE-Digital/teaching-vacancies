require 'google/apis/drive_v3'

class DocumentUpload
  class MissingUploadPath < StandardError; end
  attr_accessor :drive_service, :upload_path, :name, :uploaded, :safe_download

  def initialize(opts = {})
    raise MissingUploadPath if opts[:upload_path].nil?
    self.upload_path = opts[:upload_path]
    self.name = opts[:name]
    self.drive_service = Google::Apis::DriveV3::DriveService.new
  end

  def upload
    upload_hiring_staff_document
    set_public_permission_on_document
    google_drive_virus_check
  end

  def upload_hiring_staff_document
    self.uploaded = drive_service.create_file(
      { alt: 'media', name: name },
      fields: 'id, web_view_link, web_content_link, mime_type',
      upload_source: upload_path
    )
  end

  def set_public_permission_on_document
    drive_service.create_permission(
      uploaded.id,
      Google::Apis::DriveV3::Permission.new(type: 'anyone', role: 'reader')
    )
  end

  def google_drive_virus_check
    download_path = "#{uploaded.id}"
    begin
      drive_service.get_file(
        uploaded.id,
        acknowledge_abuse: false,
        download_dest: download_path
      )
    rescue Google::Apis::ClientError
      drive_service.delete_file(uploaded.id)
      self.safe_download = false
    else
      self.safe_download = true
    ensure
      File.delete(download_path) if File.exist?(download_path)
    end
  end
end
