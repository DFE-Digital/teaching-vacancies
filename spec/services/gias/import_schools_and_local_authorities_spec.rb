require "rails_helper"

RSpec.describe Gias::ImportSchoolsAndLocalAuthorities do
  subject { described_class.new }

  describe "#call" do
    let(:csv) { File.read(test_file_path) }
    let(:datestring) { Time.current.strftime("%Y%m%d") }
    let(:example_school) { School.find_by(urn: "100000") }
    let(:test_file_path) { Rails.root.join("spec/fixtures/example_schools_data.csv") }

    let(:local_authority1) { SchoolGroup.find_by(local_authority_code: "201") }
    let(:local_authority2) { SchoolGroup.find_by(local_authority_code: "202") }

    before do
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
      ).to_return(body: csv)
    end

    it "creates Schools" do
      expect { subject.call }.to change(School, :count).to eq(9)
    end

    it "creates SchoolGroups" do
      expect { subject.call }.to change(SchoolGroup, :count).to eq(2)
    end

    it "creates SchoolGroupMemberships" do
      expect { subject.call }.to change(SchoolGroupMembership, :count).to eq(9)
    end

    it "links the correct schools and local authorities" do
      subject.call
      expect(local_authority1.schools).to include(School.find_by(urn: "100000"))
      expect(local_authority1.schools).to include(School.find_by(urn: "100001"))
      expect(local_authority1.schools).to include(School.find_by(urn: "100002"))
      expect(local_authority1.schools).to include(School.find_by(urn: "100003"))
      expect(local_authority2.schools).to include(School.find_by(urn: "100004"))
      expect(local_authority2.schools).to include(School.find_by(urn: "100005"))
      expect(local_authority2.schools).to include(School.find_by(urn: "100006"))
      expect(local_authority2.schools).to include(School.find_by(urn: "100007"))
      expect(local_authority2.schools).to include(School.find_by(urn: "100008"))
    end

    it "stores the expected attributes" do
      subject.call
      expect(example_school).not_to be_blank
      expect(example_school.gias_data).not_to be_blank
      expect(example_school.address3).to be_nil
      expect(example_school.county).to be_nil
      expect(example_school.detailed_school_type).to eq("Voluntary aided school")
      expect(example_school.establishment_status).to eq("Open")
      expect(example_school.locality).to eq("Duke's Place")
      expect(example_school.local_authority_within).to eq("City of London")
      expect(example_school.name).to eq("Sir John Cass's Foundation Primary School")
      expect(example_school.phase).to eq("primary")
      expect(example_school.region).to eq("London")
      expect(example_school.school_type).to eq("LA maintained school")
      expect(example_school.url).to eq("http://www.sirjohncassprimary.org")
    end

    it "sets geolocation" do
      subject.call
      expect(example_school.geopoint.lat).to be_within(0.0001).of(51.51396894535262)
      expect(example_school.geopoint.lon).to be_within(0.0001).of(-0.07751626505544208)
    end

    context "when the CSV contains smart-quotes using Windows 1252 encoding" do
      before do
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
        ).to_return(body:
                    "URN,EstablishmentName,EstablishmentTypeGroup (code)," \
                    "TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street," \
                    "Town,Postcode\n" \
                    "100000,St John\x92s School,999,999,ZZZ,http://test.com,?,?,?")
      end

      it "converts the file to UTF-8" do
        subject.call
        expect(example_school.name).to eq("St John’s School")
      end
    end

    context "when the CSV contains an incomplete school website URL" do
      it "is converted to include the protocol" do
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
        ).to_return(body:
                    "URN,EstablishmentName,EstablishmentTypeGroup (code)," \
                    "TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street," \
                    "Town,Postcode\n" \
                    "100000,St John\x92s School,999,999,ZZZ,test.com,?,?,?")
        subject.call
        expect(example_school.url).to eq("http://test.com")
      end

      it "does not return a value if the website is not set" do
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{datestring}.csv",
        ).to_return(body:
                    "URN,EstablishmentName,EstablishmentTypeGroup (code)," \
                    "TypeOfEstablishment (code),GOR (code),SchoolWebsite,Street," \
                    "Town,Postcode\n" \
                    "100000,St John\x92s School,999,999,ZZZ,,?,?,?")
        subject.call
        expect(example_school.url).to be_nil
      end
    end
  end
end
