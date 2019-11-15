require 'rails_helper'
require 'spreadsheet_writer'
RSpec.describe 'Spreadsheet::Writer' do
  before(:each) do
    stub_const('GOOGLE_DRIVE_JSON_KEY', 'google-key')
  end

  let(:session) { double(:session) }
  let(:worksheet) { double(max_rows: 0, save: nil) }
  let(:spreadsheet) { double(worksheets: [worksheet]) }

  describe 'it writes to a specified worksheet' do
    it 'the worksheet position can be configured' do
      worksheet = double(max_rows: 2)
      spreadsheet = double(worksheets: [double(max_rows: 0, save: nil),
                                        worksheet])
      worksheet_position = 1

      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)
      expect(worksheet).to receive(:save)

      Spreadsheet::Writer.new(:spreadsheet_id, worksheet_position).append_row([])
    end

    context 'when use_gid? is set' do
      it 'the worksheet position can be configured' do
        worksheet = double(max_rows: 2)
        spreadsheet = double
        gid = 2051310096

        expect(GoogleDrive::Session).to receive(:from_service_account_key) { session }
        expect(session).to receive(:spreadsheet_by_key) { spreadsheet }
        expect(spreadsheet).to receive(:worksheet_by_gid).with(gid) { worksheet }
        expect(worksheet).to receive(:save)

        Spreadsheet::Writer.new(:spreadsheet_id, gid, true).append_row([])
      end
    end
  end

  describe '#append_row' do
    let(:data) { ['foo', 'bar'] }

    it 'creates a new instance of a Google Drive session' do
      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

      Spreadsheet::Writer.new(:spreadsheet_id).append_row([])
    end

    it 'writes a row' do
      allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

      expect(worksheet).to receive(:[]=).with(1, 1, data[0])
      expect(worksheet).to receive(:[]=).with(1, 2, data[1])
      expect(worksheet).to receive(:save).once

      Spreadsheet::Writer.new(:spreadsheet_id).append_row(data)
    end

    context 'when there are already rows present' do
      let(:worksheet) { double(max_rows: 100, save: nil) }

      it 'writes a row' do
        allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
        allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

        expect(worksheet).to receive(:[]=).with(101, 1, data[0])
        expect(worksheet).to receive(:[]=).with(101, 2, data[1])
        expect(worksheet).to receive(:save).once

        Spreadsheet::Writer.new(:spreadsheet_id).append_row(data)
      end
    end
  end

  describe '#append_rows' do
    let(:data) { [['foo', 'bar'], ['baz', 'foo'], ['fizz', 'buzz']] }

    it 'creates a new instance of a Google Drive session' do
      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

      Spreadsheet::Writer.new(:spreadsheet_id).append_rows([[], []])
    end

    it 'writes the rows' do
      allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

      expect(worksheet).to receive(:[]=).with(1, 1, data[0][0])
      expect(worksheet).to receive(:[]=).with(1, 2, data[0][1])
      expect(worksheet).to receive(:[]=).with(2, 1, data[1][0])
      expect(worksheet).to receive(:[]=).with(2, 2, data[1][1])
      expect(worksheet).to receive(:[]=).with(3, 1, data[2][0])
      expect(worksheet).to receive(:[]=).with(3, 2, data[2][1])
      expect(worksheet).to receive(:save).once

      Spreadsheet::Writer.new(:spreadsheet_id).append_rows(data)
    end

    context 'when there are already rows present' do
      let(:worksheet) { double(max_rows: 100, save: nil) }

      it 'writes the rows' do
        allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
        allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

        expect(worksheet).to receive(:[]=).with(101, 1, data[0][0])
        expect(worksheet).to receive(:[]=).with(101, 2, data[0][1])
        expect(worksheet).to receive(:[]=).with(102, 1, data[1][0])
        expect(worksheet).to receive(:[]=).with(102, 2, data[1][1])
        expect(worksheet).to receive(:[]=).with(103, 1, data[2][0])
        expect(worksheet).to receive(:[]=).with(103, 2, data[2][1])
        expect(worksheet).to receive(:save).once

        Spreadsheet::Writer.new(:spreadsheet_id).append_rows(data)
      end
    end
  end

  describe '#last_row' do
    let(:data) { [['foo', 'bar'], ['fizz', 'buzz']] }
    let(:worksheet) { double(max_rows: 2, save: nil, rows: double) }
    let(:spreadsheet) { double(worksheets: [worksheet]) }
    let(:row) { Spreadsheet::Writer.new(:spreadsheet_id).last_row }

    before do
      allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)
      allow(worksheet.rows).to receive(:[]) { |arg| data[arg] }
    end

    it 'gets the last row' do
      expect(row).to eq(data.last)
    end

    context 'when the spreadsheet is blank' do
      let(:data) { [] }

      it 'returns nil' do
        expect(row).to eq(nil)
      end
    end
  end

  describe '#clear_all_rows' do
    it 'creates a new instance of a Google Drive session' do
      expect(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
      expect(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)

      Spreadsheet::Writer.new(:spreadsheet_id).clear_all_rows
    end

    context 'when a spreadsheet has data in it' do
      let(:worksheet) { double(max_rows: 10, save: nil, reload: nil) }

      before(:each) do
        allow(GoogleDrive::Session).to receive(:from_service_account_key).and_return(session)
        allow(session).to receive(:spreadsheet_by_key).and_return(spreadsheet)
      end

      it 'ignores the first row' do
        # The first row would contain the column titles.
        # We do not want to delete these, only the column values.

        expect(worksheet).to_not receive(:delete_rows).with(1, 9)

        Spreadsheet::Writer.new(:spreadsheet_id).clear_all_rows
      end

      it 'deletes all the rows with data' do
        expect(worksheet).to receive(:delete_rows).with(2, 9)
        expect(worksheet).to receive(:save).once

        Spreadsheet::Writer.new(:spreadsheet_id).clear_all_rows
      end
    end

    context 'when a spreadsheet has no data in it' do
      let(:worksheet) { double(max_rows: 0, save: nil) }

      it 'does not attempt to clear it' do
        expect(worksheet).to_not receive(:delete_rows).with(0, 0)
      end
    end
  end
end
