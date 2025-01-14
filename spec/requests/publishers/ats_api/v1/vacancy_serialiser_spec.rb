require "rails_helper"

RSpec.describe Publishers::AtsApi::V1::VacancySerialiser do
  describe "#call" do
    subject(:serialiser) { described_class.new(vacancy: vacancy) }

    let(:school) { create(:school, urn: "12345") }
    let(:vacancy) { create(:vacancy, :external, ect_status: :ect_suitable, organisations: [school]) }
    let(:ect_suitable) { true }
    let(:organisation_urns) { { school_urns: [school.urn] } }

    let(:expected_serialised_vacancy) do
      {
        id: vacancy.id,
        external_advert_url: vacancy.external_advert_url,
        publish_on: vacancy.publish_on,
        expires_at: vacancy.expires_at,
        job_title: vacancy.job_title,
        skills_and_experience: vacancy.skills_and_experience,
        salary: vacancy.salary,
        benefits_details: vacancy.benefits_details,
        starts_on: vacancy.starts_on,
        external_reference: vacancy.external_reference,
        visa_sponsorship_available: vacancy.visa_sponsorship_available,
        is_job_share: vacancy.is_job_share,
        schools: organisation_urns,
        job_roles: vacancy.job_roles,
        ect_suitable: ect_suitable,
        working_patterns: vacancy.working_patterns,
        contract_type: vacancy.contract_type,
        phases: vacancy.phases,
        key_stages: vacancy.key_stages,
        subjects: vacancy.subjects,
      }
    end

    it "serializes the vacancy correctly" do
      expect(serialiser.call).to eq(expected_serialised_vacancy)
    end

    context "when the vacancy is not suitable for an ECT" do
      let(:vacancy) { create(:vacancy, :external, ect_status: :ect_unsuitable, organisations: [school]) }
      let(:ect_suitable) { false }

      it "serializes the vacancy correctly" do
        expect(serialiser.call).to eq(expected_serialised_vacancy)
      end
    end

    context "when the vacancy is at a trust" do
      let(:school_group) { create(:trust) }
      let(:organisation_urns) { { trust_uid: school_group.uid } }
      let(:vacancy) { create(:vacancy, :external, ect_status: :ect_suitable, organisations: [school_group]) }

      it "serializes the vacancy correctly" do
        expect(serialiser.call).to eq(expected_serialised_vacancy)
      end
    end

    context "when the vacancy is at multiple schools and a trust central branch" do
      let(:school_group) { create(:trust) }
      let(:schools) { create_list(:school, 3) }
      let(:organisation_urns) { { trust_uid: school_group.uid, school_urns: schools.map(&:urn).sort } }
      let(:vacancy) { create(:vacancy, :external, ect_status: :ect_suitable, organisations: schools + [school_group]) }

      before do
        school_group.schools << schools
      end

      it "serializes the vacancy correctly" do
        serialised_vacancy = serialiser.call
        serialised_vacancy[:schools][:school_urns] = serialised_vacancy[:schools][:school_urns].sort

        expect(serialised_vacancy).to eq(expected_serialised_vacancy)
      end
    end
  end
end
