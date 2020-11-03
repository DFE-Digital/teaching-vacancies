require "google/apis/drive_v3"

class DocumentCopy
  class MissingDocumentId < StandardError; end
  attr_accessor :drive_service, :document_id, :google_error, :copied

  def initialize(document_id)
    raise MissingDocumentId unless document_id

    self.drive_service = Google::Apis::DriveV3::DriveService.new
    self.document_id = document_id
    self.google_error = false
  end

  def copy
    copy_hiring_staff_document
    set_public_permission_on_document
  rescue Google::Apis::Error
    self.google_error = true
  end

  def copy_hiring_staff_document
    self.copied = drive_service.copy_file(
      document_id,
      fields: "id, web_view_link, web_content_link, mime_type",
    )
  end

  def set_public_permission_on_document
    drive_service.create_permission(
      copied.id,
      Google::Apis::DriveV3::Permission.new(type: "anyone", role: "reader"),
    )
  end
end
