require 'rails_helper'
require 'open-uri'

RSpec.describe UpdateSchoolsDataFromSourceJob, type: :job do
  before do
    # Associated records that already exist
    @la_maintained_school_type = SchoolType.create!(label: 'LA maintained school', code: '4')
    @voluntary_aided_school = DetailedSchoolType.create!(label: 'Voluntary aided school', code: '02')
    @london = Region.create(name: 'London', code: 'H')
  end

  context 'When the CSV is unavailable' do
    before do
      datestring = Time.zone.now.strftime('%Y%m%d')
      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body: 'Not Found', status: 404)
    end

    it 'should raise an HTTP error' do
      expect { UpdateSchoolsDataFromSourceJob.new.perform }.to raise_error(OpenURI::HTTPError)
    end
  end

  context 'where the CSV contains smart-quotes using Windows 1252 encoding' do
    before do
      datestring = Time.zone.now.strftime('%Y%m%d')

      stub_request(:get, "http://ea-edubase-api-prod.azurewebsites.net/edubase/edubasealldata#{datestring}.csv")
        .to_return(body:
          'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
          'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
          "Town,Postcode\n" \
          "100000,St John\x92s School,999,999,ZZZ,http://test.com,?,?,?")

      @school = School.create!(
        urn: '100000',
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
        school_type: SchoolType.create!(label: 'Previous school type', code: '999'),
        detailed_school_type: DetailedSchoolType.create!(label: 'Previous detailed school type', code: '999'),
        region: Region.create!(name: 'Previous region', code: 'ZZZ'),
        phase: 'all_through'
      )
    end

    it 'should correct convert the file to UTF-8' do
      UpdateSchoolsDataFromSourceJob.new.perform

      @school.reload

      expect(@school.name).to eql('St John’s School')
    end
  end

  context 'when the CSV is available' do
    before do
      datestring = Time.zone.now.strftime('%Y%m%d')

      csv = File.read(Rails.root.join('spec', 'fixtures', 'example_schools_data.csv'))
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
        expect(school.school_type).to eql(@la_maintained_school_type)
        expect(school.detailed_school_type).to eql(@voluntary_aided_school)
        expect(school.region).to eql(@london)
        expect(school.phase).to eql('primary')

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
        expect(school.region).to eql(@london)
        expect(school.phase).to eql('not_applicable')

        expect(School.find_by(urn: '100002')).to be_present
        expect(School.find_by(urn: '100003')).to be_present
        expect(School.find_by(urn: '100004')).to be_present
        expect(School.find_by(urn: '100005')).to be_present
        expect(School.find_by(urn: '100006')).to be_present
        expect(School.find_by(urn: '100007')).to be_present
        expect(School.find_by(urn: '100008')).to be_present
      end
    end

    context 'and a school was already in the database' do
      before do
        @school = School.create!(
          urn: '100000',
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
          school_type: SchoolType.create!(label: 'Previous school type', code: '999'),
          detailed_school_type: DetailedSchoolType.create!(label: 'Previous detailed school type', code: '999'),
          region: Region.create!(name: 'Previous region', code: 'ZZZ'),
          phase: 'all_through'
        )
      end

      it 'should update the school details' do
        UpdateSchoolsDataFromSourceJob.new.perform

        @school.reload # Re-fetch from the database

        expect(@school.name).to eql("Sir John Cass's Foundation Primary School")
        expect(@school.address).to eql("St James's Passage")
        expect(@school.locality).to eql("Duke's Place")
        expect(@school.address3).to eql(nil)
        expect(@school.town).to eql('London')
        expect(@school.county).to eql(nil)
        expect(@school.postcode).to eql('EC3A 5DE')
        expect(@school.minimum_age).to eql(3)
        expect(@school.maximum_age).to eql(11)
        expect(@school.url).to eql('http://www.sirjohncassprimary.org')
        expect(@school.school_type).to eql(@la_maintained_school_type)
        expect(@school.detailed_school_type).to eql(@voluntary_aided_school)
        expect(@school.region).to eql(@london)
        expect(@school.phase).to eql('primary')
      end
    end
  end
end