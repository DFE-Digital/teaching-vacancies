require 'rails_helper'
require 'import_school_group_data'

RSpec.describe ImportSchoolGroupData do
  let(:subject) { ImportSchoolGroupData.new }

  let(:csv_url) { 'https://csv_endpoint.csv/magic_endpoint/test.csv' }
  let(:temp_file_location) { '/some_temporary_location/test.csv' }

  context '#convert_to_school_group' do
    let(:row) { { 'Group UID': uid } }
    let(:school_group) { double('school_group') }
    let(:uid) { 'test_uid' }

    before do
      allow(SchoolGroup).to receive(:find_or_initialize_by).with(
        hash_including(uid: row['Group UID'])).and_return(school_group)
      allow(subject).to receive(:set_gias_data_as_json).with(school_group, row)
    end

    it 'calls set_gias_data_as_json' do
      expect(subject).to receive(:set_gias_data_as_json).with(school_group, row)
      subject.send(:convert_to_school_group, row)
    end
  end

  context '#save_csv_file' do
    let(:request_body) { 'Not found' }

    before do
      stub_request(:get, csv_url).to_return(body: request_body, status: request_status)
    end

    context 'csv file is unavailable' do
      let(:request_status) { 404 }

      it 'raises an HTTP error' do
        expect { subject.send(:save_csv_file, csv_url, temp_file_location) }.to raise_error do
          HTTParty::ResponseError.new('SchoolGroup CSV file not found.')
        end
      end
    end

    context 'an unexpected response is returned' do
      let(:request_status) { 500 }

      it 'raises an HTTP error' do
        expect { subject.send(:save_csv_file, csv_url, temp_file_location) }.to raise_error do
          HTTParty::ResponseError.new('Unexpected problem downloading SchoolGroup CSV file.')
        end
      end
    end

    context 'the request is OK' do
      let(:request_status) { 200 }

      before do
        allow(File).to receive(:write).with(temp_file_location, request_body, hash_including(mode: 'wb'))
      end

      it 'opens a file' do
        expect(File).to receive(:write).with(temp_file_location, request_body, hash_including(mode: 'wb'))
        subject.send(:save_csv_file, csv_url, temp_file_location)
      end
    end
  end
end
