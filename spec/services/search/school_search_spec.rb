require "rails_helper"

RSpec.describe Search::SchoolSearch do
  subject { described_class.new(form_hash, scope: scope) }

  let(:form_hash) do
    {
      name: name,
      location: ([location, radius] if location.present?),
      organisation_types: organisation_types,
      key_stage: key_stage,
      special_school: special_school,
      job_availability: job_availability,
    }.compact
  end

  let(:name) { nil }
  let(:location) { nil }
  let(:organisation_types) { nil }
  let(:key_stage) { nil }
  let(:special_school) { nil }
  let(:job_availability) { nil }
  let(:radius) { 10 }

  let(:scope) { School.all }

  context "when no filters (except for radius) are given" do
    it "returns unmodified scope" do
      expect(subject.organisations.to_sql).to eq(scope.to_sql)
    end
  end

  context "when location and radius are given" do
    let(:location) { "Sevenoaks" }

    it "returns scope modified by location search" do
      expect(subject.organisations.to_sql).to eq(scope.search_by_location(location, radius).to_sql)
    end
  end

  context "when only name is given" do
    let(:radius) { nil }
    let(:name) { "Bexleyheath Academy" }

    it "returns scope modified by name search" do
      expect(subject.organisations.to_sql).to eq(scope.search_by_name(name).to_sql)
    end
  end

  context "when organisation_types are given" do
    let!(:academies) { create(:school, name: "Academy1", school_type: "Academies") }
    let!(:academy) { create(:school, name: "Academy2", school_type: "Academy") }
    let!(:free_school) { create(:school, name: "Freeschool1", school_type: "Free school") }
    let!(:free_schools) { create(:school, name: "Freeschool2", school_type: "Free schools") }
    let!(:local_authority_school) { create(:school, name: "local authority", school_type: "Local authority maintained schools") }
    let!(:other_school) { create(:school, name: "local authority", school_type: "Something else") }

    context "when organisation_types == ['Academy']" do
      let(:organisation_types) { ["Academy"] }

      it "will return academies and free schools" do
        expect(subject.organisations).to contain_exactly(academies, academy, free_school, free_schools)
      end
    end

    context "when organisation_types == ['Local authority maintained schools']" do
      let(:organisation_types) { ["Local authority maintained schools"] }

      it "will return local authority maintained schools" do
        expect(subject.organisations).to contain_exactly(local_authority_school)
      end
    end

    context "when organisation_types is empty" do
      it "will return all schools" do
        expect(subject.organisations).to contain_exactly(academies, academy, free_school, free_schools, local_authority_school, other_school)
      end
    end

    context "when organisation_types includes both 'Academy' and 'Local authority maintained schools'" do
      let(:organisation_types) { ["Academy", "Local authority maintained schools"] }
      it "will return local authority maintained schools, academies and free schools" do
        expect(subject.organisations).to contain_exactly(academies, academy, free_school, free_schools, local_authority_school)
      end
    end
  end

  context "when clearing filters" do
    let(:name) { "Bexleyheath Academy" }
    let(:location) { "Sevenoaks" }
    let(:organisation_types) { ["Academy"] }
    let(:key_stage) { ["ks2"] }
    let(:special_school) { "1" }
    let(:job_availability) { "true" }

    it "clears selected filters " do
      expect(subject.active_criteria).to eq({ location: ["Sevenoaks", 10], name: name, organisation_types: organisation_types, job_availability: job_availability, key_stage: key_stage, special_school: special_school })
      expect(subject.clear_filters_params).to eq({ location: ["Sevenoaks", 10], name: name, organisation_types: [], education_phase: [], key_stage: [], special_school: [], job_availability: [] })
    end
  end
end
