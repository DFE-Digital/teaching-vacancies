require 'google_drive'
module Spreadsheet
  class Writer
    def initialize(spreadsheet_id)
      @spreadsheet_id = spreadsheet_id
    end

    def append(rows)
      last_pos = worksheet.num_rows
      rows.each_with_index do |row, i|
        pos = last_pos + i + 1
        row.each_with_index do |cell, index|
          worksheet[pos, index + 1] = cell
        end
      end
      worksheet.save
    end

    private

    def key
      @key ||= StringIO.new(GOOGLE_DRIVE_JSON_KEY)
    end

    def session
      @session ||= GoogleDrive::Session.from_service_account_key(key)
    end

    def worksheet
      @worksheet ||= session.spreadsheet_by_key(spreadsheet_id).worksheets[0]
    end

    attr_reader :spreadsheet_id
  end
end
