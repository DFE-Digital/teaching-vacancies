require "rails_helper"

RSpec.describe ImportOrganisationDataJob do
  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context "when DisableExpensiveJobs is not enabled" do
    let(:disable_expensive_jobs_enabled?) { false }
    let(:import_school_data) { instance_double("ImportSchoolData") }
    let(:import_trust_data) { instance_double("ImportTrustData") }

    it "executes perform" do
      expect(ImportSchoolData).to receive(:new).and_return(import_school_data)
      expect(ImportTrustData).to receive(:new).and_return(import_trust_data)

      expect(import_school_data).to receive(:run!)
      expect(import_trust_data).to receive(:run!)

      perform_enqueued_jobs { job }
    end

    context "when there are some old memberships in the database that are not in the latest imported data" do
      let(:stubbed_date) { Time.utc(2021, 2, 1, 12, 0, 0) }
      let(:todays_date) { stubbed_date.strftime("%Y%m%d") }
      let(:trusts_csv) { File.read(Rails.root.join("spec/fixtures/example_groups_data.csv")) }
      let(:trust_memberships_csv) { File.read(Rails.root.join("spec/fixtures/example_links_data.csv")) }
      let(:schools_csv) { File.read(Rails.root.join("spec/fixtures/example_schools_data.csv")) }
      let(:trust) { create(:trust, uid: "2044") }
      let(:local_authority) { create(:local_authority, local_authority_code: "202", name: "Camden", group_type: "local_authority") }
      let(:school1) { create(:academy, urn: "100003") }
      let(:school2) { create(:academy, urn: "100000") }
      let(:school3) { create(:academy, urn: "100004") }

      let!(:memberships_to_delete) do
        SchoolGroupMembership.create(school_id: school1.id, school_group_id: trust.id, do_not_delete: true)
        SchoolGroupMembership.create(school_id: school1.id, school_group_id: local_authority.id, do_not_delete: true)
      end

      let!(:memberships_to_keep) do
        SchoolGroupMembership.create(school_id: school2.id, school_group_id: trust.id, do_not_delete: true)
        SchoolGroupMembership.create(school_id: school3.id, school_group_id: local_authority.id, do_not_delete: true)
      end

      before do
        travel_to stubbed_date
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/allgroupsdata#{todays_date}.csv",
        ).to_return(body: trusts_csv)
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/alllinksdata#{todays_date}.csv",
        ).to_return(body: trust_memberships_csv)
        stub_request(
          :get,
          "https://ea-edubase-api-prod.azurewebsites.net/edubase/downloads/public/edubasealldata#{todays_date}.csv",
        ).to_return(body: schools_csv)
        perform_enqueued_jobs { job }
      end

      after do
        travel_back
      end

      it "deletes old memberships that are not in the response" do
        expect(trust.schools).not_to include(school1)
        expect(local_authority.schools).not_to include(school1)
      end

      it "keeps old memberships that should be kept" do
        expect(trust.schools).to include(school2)
        expect(local_authority.schools).to include(school3)
      end
    end
  end

  context "when DisableExpensiveJobs is enabled" do
    let(:disable_expensive_jobs_enabled?) { true }

    it "does not perform the job" do
      expect(ImportSchoolData).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
