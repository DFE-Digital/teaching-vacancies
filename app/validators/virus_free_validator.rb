# TODO: - this could be deleted when we move over to Azure storage, which will do the virus check for us
class VirusFreeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    changes = record.attachment_changes[attribute.to_s]
    if changes
      changes.attachables.select { |d| d.instance_of?(ActionDispatch::Http::UploadedFile) }.each do |upload_file|
        # :nocov:
        unless Publishers::DocumentVirusCheck.new(upload_file.tempfile).safe?
          Rails.logger.warn("Attempted to upload '#{upload_file.original_filename}' but Google Drive virus check failed")
          record.errors.add(attribute, :contains_a_virus)
        end
        # :nocov:
      end
    end
  end
end
