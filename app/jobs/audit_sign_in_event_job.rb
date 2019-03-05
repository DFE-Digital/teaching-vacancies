require 'message_encryptor'

class AuditSignInEventJob < SpreadsheetWriterJob
  WORKSHEET_POSITION = 1
  queue_as :audit_sign_in_event

  def perform(audit_details)
    return unless AUDIT_SPREADSHEET_ID

    write_row(decrypt_data(audit_details), WORKSHEET_POSITION)
  end

  private

  def decrypt_data(data)
    MessageEncryptor.new(data).decrypt
  end
end
