require 'spreadsheet_writer'
require 'message_encryptor'

class AuditSignInEventJob < ApplicationJob
  queue_as :audit_sign_in_event

  def perform(audit_details)
    return unless PUBLISHED_VACANCY_SPREADSHEET_ID

    write_row(decrypt_data(audit_details))
  end

  private

  def write_row(row)
    worksheet = Spreadsheet::Writer.new(PUBLISHED_VACANCY_SPREADSHEET_ID, 1)
    worksheet.append(row)
  end

  def decrypt_data(data)
    MessageEncryptor.new(data).decrypt
  end
end
