require "rails_helper"

RSpec.describe Search::SchoolSearch do
  subject { described_class.new(form_hash, scope: scope) }

  let(:form_hash) do
    {
      name: name,
      location: ([location, radius] if location.present?),
      organisation_types: organisation_types,
      key_stage: key_stage,
      job_availability: job_availability,
      school_types: school_types,
    }.compact
  end

  let(:name) { nil }
  let(:location) { nil }
  let(:organisation_types) { nil }
  let(:school_types) { nil }
  let(:key_stage) { nil }
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

      it "returns academies and free schools" do
        expect(subject.organisations).to contain_exactly(academies, academy, free_school, free_schools)
      end
    end

    context "when organisation_types == ['Local authority maintained schools']" do
      let(:organisation_types) { ["Local authority maintained schools"] }

      it "returns local authority maintained schools" do
        expect(subject.organisations).to contain_exactly(local_authority_school)
      end
    end

    context "when organisation_types is empty" do
      it "returns all schools" do
        expect(subject.organisations).to contain_exactly(academies, academy, free_school, free_schools, local_authority_school, other_school)
      end
    end

    context "when organisation_types includes both 'Academy' and 'Local authority maintained schools'" do
      let(:organisation_types) { ["Academy", "Local authority maintained schools"] }

      it "returns local authority maintained schools, academies and free schools" do
        expect(subject.organisations).to contain_exactly(academies, academy, free_school, free_schools, local_authority_school)
      end
    end
  end

  context "when school_types are given" do
    let(:special_school1) { create(:school, name: "Community special school", detailed_school_type: "Community special school") }
    let(:special_school2) { create(:school, name: "Foundation special school", detailed_school_type: "Foundation special school") }
    let(:special_school3) { create(:school, name: "Non-maintained special school", detailed_school_type: "Non-maintained special school") }
    let(:special_school4) { create(:school, name: "Academy special converter", detailed_school_type: "Academy special converter") }
    let(:special_school5) { create(:school, name: "Academy special sponsor led", detailed_school_type: "Academy special sponsor led") }
    let(:special_school6) { create(:school, name: "Non-maintained special school", detailed_school_type: "Free schools special") }
    let(:faith_school) { create(:school, name: "Religious", gias_data: { "ReligiousCharacter (name)" => "anything" }) }
    let(:non_faith_school1) { create(:school, name: "nonfaith1", gias_data: { "ReligiousCharacter (name)" => "" }) }
    let(:non_faith_school2) { create(:school, name: "nonfaith2", gias_data: { "ReligiousCharacter (name)" => "Does not apply" }) }
    let(:non_faith_school3) { create(:school, name: "nonfaith3", gias_data: { "ReligiousCharacter (name)" => "None" }) }
    let!(:other_school) { create(:school, name: "other", detailed_school_type: "Something else") }

    context "when school_types == ['faith_school']" do
      let(:school_types) { ["faith_school"] }

      it "returns faith schools" do
        expect(subject.organisations).to contain_exactly(faith_school)
      end
    end

    context "when school_types == ['special_school']" do
      let(:school_types) { ["special_school"] }

      it "returns special schools" do
        expect(subject.organisations).to contain_exactly(special_school1, special_school2, special_school3, special_school4, special_school5, special_school6)
      end
    end

    context "when school_types is empty" do
      it "returns all schools" do
        expect(subject.organisations).to contain_exactly(special_school1, special_school2, special_school3, special_school4, special_school5, special_school6, faith_school, other_school, non_faith_school1, non_faith_school2, non_faith_school3)
      end
    end

    context "when school_types includes both 'faith_school' and 'special_school'" do
      let(:school_types) { %w[faith_school special_school] }

      it "returns special schools and faith schools" do
        expect(subject.organisations).to contain_exactly(special_school1, special_school2, special_school3, special_school4, special_school5, special_school6, faith_school)
      end
    end
  end

  context "when clearing filters" do
    let(:name) { "Bexleyheath Academy" }
    let(:location) { "Sevenoaks" }
    let(:organisation_types) { ["Academy"] }
    let(:key_stage) { ["ks2"] }
    let(:job_availability) { "true" }
    let(:school_types) { ["special_school"] }

    it "clears selected filters" do
      expect(subject.active_criteria).to eq({ location: ["Sevenoaks", 10], name: name, organisation_types: organisation_types, job_availability: job_availability, key_stage: key_stage, school_types: school_types })
      expect(subject.clear_filters_params).to eq({ location: ["Sevenoaks", 10], name: name, organisation_types: [], education_phase: [], key_stage: [], job_availability: [], school_types: [] })
    end
  end
end
