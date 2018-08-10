require 'rails_helper'
require 'open-uri'

RSpec.describe UpdateSchoolsDataFromSourceJob, type: :job do
  let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'example_schools_data.csv') }
  let(:datestring) { Time.zone.now.strftime('%Y%m%d') }

  before(:each) do
    temp_file_path = Rails.root.join('spec', 'fixtures', 'temp_schools_data.csv')
    allow_any_instance_of(UpdateSchoolsDataFromSourceJob)
      .to receive(:csv_file_location)
      .and_return(temp_file_path)
  end

  context 'when there is an issue with the file' do
    before do
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body: 'Not Found', status: :not_found)
    end

    context 'and a :not_found status code is returned' do
      it 'should raise an HTTP error' do
        expect do
          UpdateSchoolsDataFromSourceJob.new.perform
        end.to(raise_error { HTTParty::ResponseError.new('School CSV file not found.') })
      end
    end

    context 'and an unexpected status code is returned' do
      before do
        stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
          .to_return(body: 'Not Found', status: 500)
      end

      it 'should raise an HTTP error' do
        expect do
          UpdateSchoolsDataFromSourceJob.new.perform
        end.to(raise_error { HTTParty::ResponseError.new('Unexpected problem downloading School CSV file.') })
      end
    end
  end

  context 'when the CSV is available' do
    let(:school_type) { create(:school_type, label: 'Previous school type', code: '999') }
    let(:region) { create(:region, name: 'Previous region', code: 'ZZZ') }
    let!(:school)  do
      create(:school, urn: '100000', name: 'Hogwards Academy',
                      school_type: school_type, region: region)
    end
    let!(:la_maintained_school_type) { SchoolType.create!(label: 'LA maintained school', code: '4') }
    let!(:voluntary_aided_school) { DetailedSchoolType.create!(label: 'Voluntary aided school', code: '02') }
    let!(:london) { Region.create(name: 'London', code: 'H') }

    before do
      create(:local_authority, code: '201', name: 'London')
      create(:local_authority, code: '202', name: 'Camden')

      csv = File.read(test_file_path)
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body: csv)
    end

    context 'and it contains smart-quotes using Windows 1252 encoding' do
      before do
        stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
          .to_return(body:
                     'URN,LA (code),EstablishmentName,EstablishmentTypeGroup (code),' \
                     'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                     "Town,Postcode,LastChangedDate\n" \
                     "100000,201,St John\x92s School,999,999,ZZZ,http://test.com,?," \
                     "?,?,#{Time.zone.today.strftime('%d/%m/%y')}")
      end

      it 'it\'s correctly converted to a UTF-8 encoded file' do
        UpdateSchoolsDataFromSourceJob.new.perform

        school.reload

        expect(school.name).to eql('St John’s School')
      end
    end

    context 'and schools are not already in the database' do
      it 'adds entries for all new schools' do
        UpdateSchoolsDataFromSourceJob.new.perform

        new_school_urns = ['100002', '100003', '100004', '100005', '100006', '100007', '100008']

        school = School.find_by(urn: '100001')
        expect(school.name).to eql('City of London School for Girls')
        expect(school.local_authority.name).to eql('London')

        expect(School.where("urn in ('#{new_school_urns.join('\',\'')}')").count).to eq(7)
      end
    end

    context 'and a school is already in the database', wip: true do
      it 'updates the school details' do
        UpdateSchoolsDataFromSourceJob.new.perform

        school.reload

        expect(school.name).to eql("Sir John Cass's Foundation Primary School")
        expect(school.address).to eql("St James's Passage")
        expect(school.locality).to eql("Duke's Place")
        expect(school.address3).to eql(nil)
        expect(school.town).to eql('London')
        expect(school.county).to eql(nil)
        expect(school.postcode).to eql('EC3A 5DE')
        expect(school.minimum_age).to eql(3)
        expect(school.maximum_age).to eql(11)
        expect(school.url).to eql('http://www.sirjohncassprimary.org')
        expect(school.school_type).to eql(la_maintained_school_type)
        expect(school.detailed_school_type).to eql(voluntary_aided_school)
        expect(school.region).to eql(london)
        expect(school.phase).to eql('primary')
        expect(school.easting).to eql('533498')
        expect(school.northing).to eql('181201')
        expect(school.geolocation.x).to be_within(0.0000000000001).of(51.51396894535262)
        expect(school.geolocation.y).to be_within(0.0000000000001).of(-0.07751626505544208)
        expect(school.last_changed_on).to eql(Date.parse('16/09/2017'))
        expect(school.status).to eql('Open')
      end

      it 'does not update the school details if the last_changed_on has not changed', wip: true do
        date = Date.parse('16/09/2017')
        school.update(last_changed_on: date)
        UpdateSchoolsDataFromSourceJob.new.perform

        school.reload
        expect(school.last_changed_on).to eq(date)
        expect(school.name).to eq('Hogwards Academy')
        expect(school.region).to eq(region)
        expect(school.school_type).to eq(school_type)
      end
    end

    context 'website url' do
      context 'when it\'s missing the protocol' do
        it 'it correctly adds the protocol' do
          stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
            .to_return(body:
                       'URN,LA (code),EstablishmentName,EstablishmentTypeGroup (code),' \
                       'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                       "Town,Postcode,LastChangedDate\n" \
                       "100000,202,St John\x92s School,999,999,ZZZ,test.com,?,?,?,19/08/2018")
          UpdateSchoolsDataFromSourceJob.new.perform

          school.reload

          expect(school.url).to eql('http://test.com')
        end
      end

      context 'when it\'s empty' do
        it 'sets the website to nil' do
          stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
            .to_return(body:
                       'URN,LA (code),EstablishmentName,EstablishmentTypeGroup (code),' \
                       'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                       "Town,Postcode,LastChangedDate\n" \
                       "100000,202,St John\x92s School,999,999,ZZZ,,?,?,?,19/08/2019")
          UpdateSchoolsDataFromSourceJob.new.perform

          school.reload

          expect(school.url).to eql('')
        end
      end
    end
  end
end
