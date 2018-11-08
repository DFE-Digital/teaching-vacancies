require 'rails_helper'
require 'spreadsheet_writer'
RSpec.describe 'Spreadsheet::Writer' do
  before(:each) do
    stub_const('GOOGLE_DRIVE_JSON_KEY', 'google-key')
  end

  let(:session) { double(:session) }

  describe 'it writes to a specified worksheet' do
    it 'the worksheet position can be configured' do
      worksheet = double(num_rows: 2)
      spreadsheet = double(worksheets: [double(num_rows: 0, save: nil),
                                        worksheet])
      worksheet_position = 1

      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)
      expect(worksheet).to receive(:save)

      Spreadsheet::Writer.new(:spreadsheet_id, worksheet_position).append([])
    end
  end

  describe '#append' do
    it 'creates a new instance of a Google Drive session' do
      spreadsheet = double(worksheets: [double(num_rows: 0, save: nil)])

      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

      Spreadsheet::Writer.new(:spreadsheet_id).append([])
    end
  end
end
