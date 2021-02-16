require "rails_helper"

RSpec.describe ImportTrustData do
  subject { described_class.new }

  describe "#save_csv_file" do
    let(:csv_url) { "https://csv_endpoint.csv/magic_endpoint/test.csv" }
    let(:temp_file_location) { "/some_temporary_location/test.csv" }
    let(:request_body) { "Not found" }

    before do
      stub_request(:get, csv_url).to_return(body: request_body, status: request_status)
    end

    context "when the csv file is unavailable" do
      let(:request_status) { 404 }

      it "raises an HTTP error" do
        expect { subject.send(:save_csv_file, csv_url, temp_file_location) }
          .to raise_error(HTTParty::ResponseError).with_message("CSV file not found.")
      end
    end

    context "when an unexpected response is returned" do
      let(:request_status) { 500 }

      it "raises an HTTP error" do
        expect { subject.send(:save_csv_file, csv_url, temp_file_location) }
          .to raise_error(HTTParty::ResponseError).with_message("Unexpected problem downloading CSV file.")
      end
    end

    context "when the request is OK" do
      let(:request_status) { 200 }

      before do
        allow(File).to receive(:write).with(temp_file_location, request_body, hash_including(mode: "wb"))
      end

      it "opens a file" do
        expect(File).to receive(:write).with(temp_file_location, request_body, hash_including(mode: "wb"))
        subject.send(:save_csv_file, csv_url, temp_file_location)
      end
    end
  end

  describe "#set_geolocation" do
    let(:trust) { create(:trust, postcode: "some postcode") }

    context "when coordinates are not found" do
      before do
        allow_any_instance_of(Geocoding).to receive(:coordinates).and_return([0, 0])
      end

      it "does not set the coordinates" do
        subject.send(:set_geolocation, trust, "postcode")
        expect(trust.geolocation).to be_blank
      end
    end

    context "when coordinates are found" do
      it "sets the coordinates" do
        subject.send(:set_geolocation, trust, "postcode")
        expect(trust.geolocation.x).to eq(Geocoder::DEFAULT_STUB_COORDINATES[0])
        expect(trust.geolocation.y).to eq(Geocoder::DEFAULT_STUB_COORDINATES[1])
      end
    end
  end

  describe "#run!" do
    let(:todays_date) { Time.current.strftime("%Y%m%d") }
    let(:groups_csv) { File.read(groups_file_path) }
    let(:groups_file_path) { Rails.root.join("spec/fixtures/example_groups_data.csv") }
    let(:links_csv) { File.read(links_file_path) }
    let(:links_file_path) { Rails.root.join("spec/fixtures/example_links_data.csv") }

    let!(:school1) { create(:academy, urn: "100000") }
    let!(:school2) { create(:academy, urn: "100001") }
    let!(:school3) { create(:academy, urn: "100002") }

    let(:trust1) { SchoolGroup.find_by(uid: "2044") }
    let(:trust2) { SchoolGroup.find_by(uid: "2070") }

    before do
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata#{todays_date}.csv",
      ).to_return(body: groups_csv)
      stub_request(
        :get,
        "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata#{todays_date}.csv",
      ).to_return(body: links_csv)
    end

    it "creates SchoolGroups" do
      expect { subject.run! }.to change(SchoolGroup, :count).to eq(3)
    end

    it "creates SchoolGroupMemberships" do
      expect { subject.run! }.to change(SchoolGroupMembership, :count).to eq(3)
    end

    it "links the correct schools and trusts" do
      subject.run!
      expect(trust1.schools).to include(school1)
      expect(trust1.schools).to include(school2)
      expect(trust2.schools).to include(school3)
    end

    it "stores the expected attributes" do
      subject.run!
      expect(trust1).not_to be_blank
      expect(trust1.gias_data).not_to be_blank
      expect(trust1.name).to eq("Abbey Academies Trust")
      expect(trust1.group_type).to eq("Multi-academy trust")
      expect(trust1.address).to eq("Abbey Road")
      expect(trust1.county).to eq("Not recorded")
      expect(trust1.postcode).to eq("PE10 9EP")
      expect(trust1.geolocation.x.round(13)).to eq(Geocoder::DEFAULT_STUB_COORDINATES[0].round(13))
      expect(trust1.geolocation.y.round(13)).to eq(Geocoder::DEFAULT_STUB_COORDINATES[1].round(13))
    end
  end
end
