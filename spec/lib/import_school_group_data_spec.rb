require 'rails_helper'

RSpec.describe ImportSchoolGroupData do
  let(:subject) { ImportSchoolGroupData.new }

  let(:csv_url) { 'https://csv_endpoint.csv/magic_endpoint/test.csv' }
  let(:temp_file_location) { '/some_temporary_location/test.csv' }

  describe '#convert_to_school_group' do
    let(:row) { { 'Group UID': uid } }
    let(:school_group) { double('school_group') }
    let(:uid) { 'test_uid' }

    before do
      allow(SchoolGroup)
        .to receive(:find_or_initialize_by).with(hash_including(uid: row['Group UID'])).and_return(school_group)
      allow(subject).to receive(:set_gias_data_as_json).with(school_group, row)
    end

    it 'calls set_gias_data_as_json' do
      expect(subject).to receive(:set_gias_data_as_json).with(school_group, row)
      subject.send(:convert_to_school_group, row)
    end

    it 'calls set_geolocation' do
      expect(subject).to receive(:set_geolocation).with(school_group, row)
      subject.send(:convert_to_school_group, row)
    end
  end

  describe '#save_csv_file' do
    let(:request_body) { 'Not found' }

    before do
      stub_request(:get, csv_url).to_return(body: request_body, status: request_status)
    end

    context 'when the csv file is unavailable' do
      let(:request_status) { 404 }

      it 'raises an HTTP error' do
        expect { subject.send(:save_csv_file, csv_url, temp_file_location) }
          .to raise_error(HTTParty::ResponseError).with_message('CSV file not found.')
      end
    end

    context 'when an unexpected response is returned' do
      let(:request_status) { 500 }

      it 'raises an HTTP error' do
        expect { subject.send(:save_csv_file, csv_url, temp_file_location) }
          .to raise_error(HTTParty::ResponseError).with_message('Unexpected problem downloading CSV file.')
      end
    end

    context 'when the request is OK' do
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

  describe '#set_geolocation' do
    let(:school_group) { create(:school_group, gias_data: { 'Group Postcode' => 'some postcode' }) }

    context 'when coordinates are not found' do
      before do
        allow_any_instance_of(Geocoding).to receive(:coordinates).and_return([0, 0])
      end

      it 'does not set the coordinates' do
        subject.send(:set_geolocation, school_group, school_group.gias_data)
        expect(school_group.geolocation).to be_blank
      end
    end

    context 'when coordinates are found' do
      it 'sets the coordinates' do
        subject.send(:set_geolocation, school_group, school_group.gias_data)
        expect(school_group.geolocation.x).to eql(Geocoder::DEFAULT_STUB_COORDINATES[0])
        expect(school_group.geolocation.y).to eql(Geocoder::DEFAULT_STUB_COORDINATES[1])
      end
    end
  end
end
