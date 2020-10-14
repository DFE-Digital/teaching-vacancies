require 'rails_helper'

RSpec.describe ImportTrustData do
  let(:subject) { described_class.new }

  describe '#create_organisation' do
    let(:trust) { create(:trust) }
    let(:row) do
      { 'Group UID' => 'test_uid',
        'Group Postcode' => 'WA1 234',
        'Group Type (code)' => '06',
        'Group Name' => 'test trust',
        'Group Locality' => '3 Trust Street',
        'Group Town' => 'Trust Town',
        'Group County' => 'Trustshire' }
    end

    before do
      allow(SchoolGroup).to receive(:find_or_initialize_by).with(hash_including(uid: row['Group UID'])).and_return(trust)
      allow(subject).to receive(:set_gias_data_as_json).with(trust, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_complex_properties' do
      expect(subject).to receive(:set_complex_properties).with(trust, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_simple_properties' do
      expect(subject).to receive(:set_simple_properties).with(trust, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_gias_data_as_json' do
      expect(subject).to receive(:set_gias_data_as_json).with(trust, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_geolocation' do
      expect(subject).to receive(:set_geolocation).with(trust, row['Group Postcode'])
      subject.send(:create_organisation, row)
    end

    it 'updates the postcode' do
      expect(trust.postcode).to eq('WA1 234')
    end

    it 'updates the name (with title case)' do
      expect(trust.name).to eq('Test Trust')
    end

    it 'updates the address' do
      expect(trust.address).to eq('3 Trust Street')
    end

    it 'updates the town' do
      expect(trust.town).to eq('Trust Town')
    end

    it 'updates the county' do
      expect(trust.county).to eq('Trustshire')
    end
  end

  describe '#save_csv_file' do
    let(:csv_url) { 'https://csv_endpoint.csv/magic_endpoint/test.csv' }
    let(:temp_file_location) { '/some_temporary_location/test.csv' }
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
    let(:trust) { create(:trust, postcode: 'some postcode') }

    context 'when coordinates are not found' do
      before do
        allow_any_instance_of(Geocoding).to receive(:coordinates).and_return([0, 0])
      end

      it 'does not set the coordinates' do
        subject.send(:set_geolocation, trust, 'postcode')
        expect(trust.geolocation).to be_blank
      end
    end

    context 'when coordinates are found' do
      it 'sets the coordinates' do
        subject.send(:set_geolocation, trust, 'postcode')
        expect(trust.geolocation.x).to eql(Geocoder::DEFAULT_STUB_COORDINATES[0])
        expect(trust.geolocation.y).to eql(Geocoder::DEFAULT_STUB_COORDINATES[1])
      end
    end
  end

  describe '#run!' do
    let(:groups_csv) { File.read(groups_file_path) }
    let(:groups_file_path) { Rails.root.join('spec/fixtures/example_groups_data.csv') }
    let(:links_csv) { File.read(links_file_path) }
    let(:links_file_path) { Rails.root.join('spec/fixtures/example_links_data.csv') }

    let!(:school_1) { create(:academy, urn: '100000') }
    let!(:school_2) { create(:academy, urn: '100001') }
    let!(:school_3) { create(:academy, urn: '100002') }

    let(:trust_1) { SchoolGroup.find_by(uid: '2044') }
    let(:trust_2) { SchoolGroup.find_by(uid: '2070') }

    before do
      stub_request(
        :get,
        'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata.csv',
      ).to_return(body: groups_csv)
      stub_request(
        :get,
        'https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata.csv',
      ).to_return(body: links_csv)
    end

    it 'creates SchoolGroups' do
      expect { subject.run! }.to change(SchoolGroup, :count).to eql(3)
    end

    it 'creates SchoolGroupMemberships' do
      expect { subject.run! }.to change(SchoolGroupMembership, :count).to eql(3)
    end

    it 'links the correct schools and trusts' do
      subject.run!
      expect(trust_1.schools).to include(school_1)
      expect(trust_1.schools).to include(school_2)
      expect(trust_2.schools).to include(school_3)
    end

    it 'stores the expected attributes' do
      subject.run!
      expect(trust_1).not_to be_blank
      expect(trust_1.gias_data).not_to be_blank
      expect(trust_1.name).to eql('Abbey Academies Trust')
      expect(trust_1.address).to eql('Abbey Road')
      expect(trust_1.county).to eql('Not recorded')
      expect(trust_1.postcode).to eql('PE10 9EP')
      expect(trust_1.geolocation.x.round(13)).to eql(Geocoder::DEFAULT_STUB_COORDINATES[0].round(13))
      expect(trust_1.geolocation.y.round(13)).to eql(Geocoder::DEFAULT_STUB_COORDINATES[1].round(13))
    end
  end
end
