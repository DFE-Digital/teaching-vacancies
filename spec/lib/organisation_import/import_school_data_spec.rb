require 'rails_helper'

RSpec.describe ImportSchoolData do
  let(:subject) { described_class.new }

  describe '#create_organisation' do
    let(:row) { { 'URN' => 'test_urn' } }
    let(:school) { create(:school) }

    before do
      allow(School).to receive(:find_or_initialize_by).with(hash_including(urn: row['URN'])).and_return(school)
      allow(subject).to receive(:set_gias_data_as_json).with(school, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_complex_properties' do
      expect(subject).to receive(:set_complex_properties).with(school, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_simple_properties' do
      expect(subject).to receive(:set_simple_properties).with(school, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_gias_data_as_json' do
      expect(subject).to receive(:set_gias_data_as_json).with(school, row)
      subject.send(:create_organisation, row)
    end

    it 'calls set_readable_phases' do
      expect(subject).to receive(:set_readable_phases).with(school)
      subject.send(:create_organisation, row)
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

  describe '#run!' do
    let(:csv) { File.read(test_file_path) }
    let(:datestring) { Time.zone.now.strftime('%Y%m%d') }
    let(:example_school) { School.find_by(urn: '100000') }
    let(:temp_file_path) { Rails.root.join('spec/fixtures/temp_schools_data.csv') }
    let(:test_file_path) { Rails.root.join('spec/fixtures/example_schools_data.csv') }

    let(:local_authority_1) { SchoolGroup.find_by(local_authority_code: '201') }
    let(:local_authority_2) { SchoolGroup.find_by(local_authority_code: '202') }

    before do
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
      ).to_return(body: csv)
    end

    it 'creates Schools' do
      expect { subject.run! }.to change(School, :count).to eql(9)
    end

    it 'creates SchoolGroups' do
      expect { subject.run! }.to change(SchoolGroup, :count).to eql(2)
    end

    it 'creates SchoolGroupMemberships' do
      expect { subject.run! }.to change(SchoolGroupMembership, :count).to eql(6)
    end

    it 'links the correct schools and local authorities' do
      subject.run!
      expect(local_authority_1.schools).to include(School.find_by(urn: '100000'))
      expect(local_authority_2.schools).to include(School.find_by(urn: '100004'))
      expect(local_authority_2.schools).to include(School.find_by(urn: '100005'))
      expect(local_authority_2.schools).to include(School.find_by(urn: '100006'))
      expect(local_authority_2.schools).to include(School.find_by(urn: '100007'))
      expect(local_authority_2.schools).to include(School.find_by(urn: '100008'))
    end

    it 'stores the expected attributes' do
      subject.run!
      expect(example_school).not_to be_blank
      expect(example_school.gias_data).not_to be_blank
      expect(example_school.address3).to be_nil
      expect(example_school.county).to be_nil
      expect(example_school.detailed_school_type).to eql('Voluntary aided school')
      expect(example_school.locality).to eql("Duke's Place")
      expect(example_school.name).to eql("Sir John Cass's Foundation Primary School")
      expect(example_school.phase).to eql('primary')
      expect(example_school.region).to eql('London')
      expect(example_school.school_type).to eql('LA maintained schools')
      expect(example_school.url).to eql('http://www.sirjohncassprimary.org')
    end

    context 'when the CSV contains smart-quotes using Windows 1252 encoding' do
      before do
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
        ).to_return(body:
                    'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                    'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                    "Town,Postcode\n" \
                    "100000,St John\x92s School,999,999,ZZZ,http://test.com,?,?,?")
      end

      it 'should correct convert the file to UTF-8' do
        subject.run!
        expect(example_school.name).to eql('St John’s School')
      end
    end

    context 'when the CSV contains an incomplete school website URL' do
      it 'is converted to include the protocol' do
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
        ).to_return(body:
                    'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                    'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                    "Town,Postcode\n" \
                    "100000,St John\x92s School,999,999,ZZZ,test.com,?,?,?")
        subject.run!
        expect(example_school.url).to eql('http://test.com')
      end

      it 'does not return a value if the website is not set' do
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
        ).to_return(body:
                    'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                    'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                    "Town,Postcode\n" \
                    "100000,St John\x92s School,999,999,ZZZ,,?,?,?")
        subject.run!
        expect(example_school.url).to eql('')
      end
    end
  end
end
