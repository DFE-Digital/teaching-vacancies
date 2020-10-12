require 'rails_helper'

# TODO: Refactor this from a set of integration tests into a set of unit tests.
RSpec.describe UpdateSchoolData do
  let(:test_file_path) { Rails.root.join('spec/fixtures/example_schools_data.csv') }
  before(:each) do
    temp_file_path = Rails.root.join('spec/fixtures/temp_schools_data.csv')
    allow_any_instance_of(UpdateSchoolData)
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
                   local_authority: '?',
                   minimum_age: 0,
                   maximum_age: 99,
                   url: nil,
                   school_type: 'Previous school type',
                   detailed_school_type: 'Previous detailed school type',
                   region: 'Previous region',
                   phase: 'all_through')
  end

  context 'When the CSV is unavailable' do
    before do
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
      ).to_return(body: 'Not Found', status: 404)
    end

    it 'should raise an HTTP error' do
      expect { UpdateSchoolData.new.run! }.to raise_error do
        HTTParty::ResponseError.new('School CSV file not found.')
      end
    end
  end

  context 'When the edubase returns an unexpected (not 200 or 404) status code' do
    before do
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
      ).to_return(body: 'Not Found', status: 500)
    end

    it 'should raise an HTTP error' do
      expect { UpdateSchoolData.new.run! }.to raise_error do
        HTTParty::ResponseError.new('Unexpected problem downloading School CSV file.')
      end
    end
  end

  context 'where the CSV contains smart-quotes using Windows 1252 encoding' do
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
      UpdateSchoolData.new.run!

      school.reload

      expect(school.name).to eql('St John’s School')
    end
  end

  context 'when the CSV is available' do
    before do
      csv = File.read(test_file_path)
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
      ).to_return(body: csv)
    end

    context 'and the schools aren’t already in the database' do
      it 'adds all the schools (open and closed)' do
        expect { UpdateSchoolData.new.run! }.to change(School, :count).by(8)
      end

      describe 'it loads the expected attributes' do
        let(:example_school) { School.find_by(urn: '100000') }
        before do
          UpdateSchoolData.new.run!
        end

        it { expect(example_school).not_to be_blank }
        it { expect(example_school.gias_data).not_to be_blank }

        # TODO: Refactor this so that the transformations are part of the model, not this lib.
        # All of the attributes tested here have transformations applied by the lib before being saved.
        it { expect(example_school.address3).to be_nil }
        it { expect(example_school.county).to be_nil }
        it { expect(example_school.detailed_school_type).to eql('Voluntary aided school') }
        it { expect(example_school.locality).to eql("Duke's Place") }
        it { expect(example_school.name).to eql("Sir John Cass's Foundation Primary School") }
        it { expect(example_school.phase).to eql('primary') }
        it { expect(example_school.region).to eql('London') }
        it { expect(example_school.school_type).to eql('LA maintained schools') }
        it { expect(example_school.url).to eql('http://www.sirjohncassprimary.org') }
      end
    end

    context 'and a school was already in the database' do
      # The assumption is that if a single change works as expected, they all will. This isn't strictly correct, but
      # testing every expected attribute change does not substantially add to the quality of the tests.
      it 'updates the school name' do
        expect {
          UpdateSchoolData.new.run!
          school.reload
        }.to change(school, :name).from('?').to("Sir John Cass's Foundation Primary School")
      end
    end
  end

  context 'where the CSV contains an incomplete school website URL' do
    it 'is converted to include the protocol' do
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
      ).to_return(body:
                  'URN,EstablishmentName,EstablishmentTypeGroup (code),' \
                  'TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street,' \
                  "Town,Postcode\n" \
                  "100000,St John\x92s School,999,999,ZZZ,test.com,?,?,?")
      UpdateSchoolData.new.run!

      school.reload

      expect(school.url).to eql('http://test.com')
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
      UpdateSchoolData.new.run!

      school.reload

      expect(school.url).to eql('')
    end
  end
end
