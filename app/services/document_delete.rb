require "google/apis/drive_v3"

class DocumentDelete
  FILE_NOT_FOUND_STATUS_CODE = 404

  class MissingDocument < StandardError; end

  def initialize(document)
    raise MissingDocument unless document

    self.drive_service = Google::Apis::DriveV3::DriveService.new
    self.document = document
  end

  def delete
    delete_file_on_google_drive!
    document.destroy
  end

  private

  attr_accessor :document, :drive_service

  def delete_file_on_google_drive!
    drive_service.delete_file document.google_drive_id
  rescue Google::Apis::ClientError => e
    raise e unless e.status_code == FILE_NOT_FOUND_STATUS_CODE
  end
end
