require 'rails_helper'
require 'open-uri'

RSpec.describe UpdateSchoolsDataFromSourceJob, type: :job do
  let(:test_file_path) { Rails.root.join('spec', 'fixtures', 'example_schools_data.csv') }
  before(:each) do
    temp_file_path = Rails.root.join('spec', 'fixtures', 'temp_schools_data.csv')
    allow_any_instance_of(UpdateSchoolsDataFromSourceJob)
      .to receive(:csv_file_location)
      .and_return(temp_file_path)
  end

  let(:datestring) { Time.zone.now.strftime('%Y%m%d') }
  let!(:school) do
    School.create!(urn: '100000',
                   name: '?',
                   address: '?',
                   locality: '?',
                   address3: '?',
                   town: '?',
                   county: '?',
                   postcode: 'PO1 1QW',
                   minimum_age: 0,
                   maximum_age: 99,
                   url: nil,
                   school_type: SchoolType.new(label: 'Previous school type', code: '999'),
                   detailed_school_type: DetailedSchoolType.new(label: 'Previous detailed school type',
                                                                code: '999'),
                   region: Region.new(name: 'Previous region', code: 'ZZZ'),
                   phase: 'all_through')
  end

  let!(:la_maintained_school_type) { SchoolType.create!(label: 'LA maintained school', code: '4') }
  let!(:voluntary_aided_school) { DetailedSchoolType.create!(label: 'Voluntary aided school', code: '02') }
  let!(:london) { Region.create(name: 'London', code: 'H') }

  context 'When the CSV is unavailable' do
    before do
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body: 'Not Found', status: 404)
    end

    it 'should raise an HTTP error' do
      # rubocop:disable AmbiguousBlockAssociation
      expect { UpdateSchoolsDataFromSourceJob.new.perform }
        .to raise_error { HTTParty::ResponseError.new('School CSV file not found.') }
      # rubocop:enable AmbiguousBlockAssociation
    end
  end

  context 'When the edubase returns an unexpected (not 200 or 404) status code' do
    before do
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body: 'Not Found', status: 500)
    end

    it 'should raise an HTTP error' do
      # rubocop:disable AmbiguousBlockAssociation
      expect { UpdateSchoolsDataFromSourceJob.new.perform }
        .to raise_error { HTTParty::ResponseError.new('Unexpected problem downloading School CSV file.') }
      # rubocop:enable AmbiguousBlockAssociation
    end
  end

  context 'where the CSV contains smart-quotes using Windows 1252 encoding' do
    before do
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body:
                   'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                   'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                   "Town,Postcode\n" \
                   "100000,St John\x92s School,999,999,ZZZ,http://test.com,?,?,?")
    end

    it 'should correct convert the file to UTF-8' do
      UpdateSchoolsDataFromSourceJob.new.perform

      school.reload

      expect(school.name).to eql('St John’s School')
    end
  end

  context 'when the CSV is available' do
    before do
      csv = File.read(test_file_path)
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body: csv)
    end

    context 'and the schools aren’t already in the database' do
      it 'should add all the schools' do
        UpdateSchoolsDataFromSourceJob.new.perform

        school = School.find_by(urn: '100000')
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

        school = School.find_by(urn: '100001')
        expect(school.name).to eql('City of London School for Girls')
        expect(school.address).to eql("St Giles' Terrace")
        expect(school.locality).to eql('Barbican')
        expect(school.address3).to eql(nil)
        expect(school.town).to eql('London')
        expect(school.county).to eql(nil)
        expect(school.postcode).to eql('EC2Y 8BB')
        expect(school.minimum_age).to eql(7)
        expect(school.maximum_age).to eql(18)
        expect(school.url).to eql('http://www.clsg.org.uk')
        expect(school.school_type.label).to eql('Independent schools')
        expect(school.school_type.code).to eql('3')
        expect(school.detailed_school_type.label).to eql('Other independent school')
        expect(school.detailed_school_type.code).to eql('11')
        expect(school.region).to eql(london)
        expect(school.phase).to eql('not_applicable')
        expect(school.easting).to eql('532301')
        expect(school.northing).to eql('181746')
        expect(school.geolocation.x).to be_within(0.0000000000001).of(51.51914791336013)
        expect(school.geolocation.y).to be_within(0.0000000000001).of(-0.09455174037405477)

        expect(School.find_by(urn: '100002')).to be_present
        expect(School.find_by(urn: '100003')).to be_present
        expect(School.find_by(urn: '100005')).to be_present
        expect(School.find_by(urn: '100006')).to be_present
        expect(School.find_by(urn: '100007')).to be_present
        expect(School.find_by(urn: '100008')).to be_present
      end
    end

    context 'and a school was already in the database' do
      it 'should update the school details' do
        UpdateSchoolsDataFromSourceJob.new.perform

        school.reload # Re-fetch from the database

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
      end
    end
  end

  context 'where the CSV contains an incomplete school website URL' do
    it 'is converted to include the protocol' do
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body:
                   'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                   'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                   "Town,Postcode\n" \
                   "100000,St John\x92s School,999,999,ZZZ,test.com,?,?,?")
      UpdateSchoolsDataFromSourceJob.new.perform

      school.reload

      expect(school.url).to eql('http://test.com')
    end

    it 'does not return a value if the website is not set' do
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body:
                   'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                   'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                   "Town,Postcode\n" \
                   "100000,St John\x92s School,999,999,ZZZ,,?,?,?")
      UpdateSchoolsDataFromSourceJob.new.perform

      school.reload

      expect(school.url).to eql('')
    end
  end
end
