require "rails_helper"

RSpec.describe CopyVacancy do
  describe "#call" do
    let(:school) { create(:school) }

    it "creates a new vacancy as draft" do
      vacancy = create(:vacancy, organisations: [school], job_title: "Maths teacher")

      result = described_class.new(vacancy).call

      expect(result).to be_kind_of(Vacancy)
      expect(Vacancy.count).to eq(2)
      expect(result.status).to eq("draft")
      expect(result.organisations).to eq [school]
    end

    it "does not change the original vacancy" do
      # Needed to compare a FactoryBot object fields for updated_at and created_at
      # and against the record it creates in Postgres.
      travel_to(Time.zone.local(2008, 9, 1, 12, 0, 0)) do
        vacancy = create(:vacancy, job_title: "Maths teacher")

        described_class.new(vacancy).call

        expect(vacancy.attributes).to eq(Vacancy.find(vacancy.id).attributes)
      end
    end

    describe "#documents" do
      let(:vacancy) { create(:vacancy, :with_supporting_documents) }
      let(:result) { described_class.new(vacancy).call }

      it "attaches supporting document when copying a vacancy" do
        expect(result.supporting_documents.count).to eq(1)
        expect(result.supporting_documents.first.blob).to eq(vacancy.supporting_documents.first.blob)
      end
    end

    context "not all fields are copied" do
      let(:vacancy) do
        create(:vacancy,
               job_title: "Maths teacher",
               slug: "maths-teacher")
      end
      let(:result) { described_class.new(vacancy).call }

      it "does not copy the slug of a vacancy" do
        expect(Vacancy.find(result.id).slug).to_not eq("maths-teacher")
      end
    end
  end
end
