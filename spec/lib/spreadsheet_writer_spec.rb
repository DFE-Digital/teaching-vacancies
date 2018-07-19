require 'rails_helper'
require 'spreadsheet_writer'
RSpec.describe 'Spreadsheet::Writer' do
  describe '#append' do
    it 'creates a new instance of a Google Drive session' do
      stub_const('GOOGLE_DRIVE_JSON_KEY', 'google-key')
      session = double(:session)
      spreadsheet = double(worksheets: [double(num_rows: 0, save: nil)])
      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)

      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)
      Spreadsheet::Writer.new(:spreadsheet_id).append([])
    end
  end
end
