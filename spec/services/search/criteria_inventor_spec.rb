require "rails_helper"

RSpec.describe Search::CriteriaInventor do
  subject { described_class.new(vacancy) }

  let(:postcode) { "ab12 3cd" }
  let(:readable_phases) { %w[secondary primary] }
  let(:school) { create(:school, postcode: postcode, readable_phases: readable_phases) }
  let(:working_patterns) { %w[full_time part_time] }
  let(:subjects) { %w[English Maths] }
  let(:job_title) { "A wonderful job" }
  let(:job_roles) { %w[teacher send_responsible] }
  let(:location_trait) { :at_one_school }
  let(:associated_orgs) { [school] }
  let(:vacancy) do
    create(:vacancy, location_trait, organisations: associated_orgs,
                                     working_patterns: working_patterns,
                                     subjects: subjects,
                                     job_title: job_title,
                                     job_roles: job_roles)
  end

  describe "#criteria" do
    describe "location" do
      context "when vacancy is associated to a single school or trust" do
        it "sets the location to the school's postcode" do
          expect(subject.criteria[:location]).to eq(postcode)
        end

        it "sets the radius to 25" do
          expect(subject.criteria[:radius]).to eq("25")
        end
      end

      context "when the vacancy is associated to multiple schools in a school group" do
        let(:school1) { create(:school, school_groups: [local_authority]) }
        let(:school2) { create(:school, school_groups: [local_authority]) }
        let(:associated_orgs) { [school1, school2] }
        let(:location_trait) { :at_multiple_schools }
        let(:local_authority) { create(:local_authority) }

        it "sets the location to the local authority of the first school" do
          expect(subject.criteria[:location]).to eq(local_authority.read_attribute(:name))
        end

        it "sets the radius to 25" do
          expect(subject.criteria[:radius]).to eq("25")
        end
      end

      context "when the vacancy is at the central office of a trust" do
        let(:location_trait) { :central_office }
        let(:associated_orgs) { [trust] }
        let(:trust) { create(:trust) }

        it "sets the location to the trust's postcode" do
          expect(subject.criteria[:location]).to eq(trust.postcode)
        end

        it "sets the radius to 25" do
          expect(subject.criteria[:radius]).to eq("25")
        end
      end
    end

    describe "working_patterns" do
      it "does not set working_patterns" do
        expect(subject.criteria[:working_patterns]).to eq(nil)
      end
    end

    describe "phases" do
      it "sets the phases to the same as the vacancy" do
        expect(subject.criteria[:phases]).to eq(readable_phases)
      end
    end

    describe "job_roles" do
      context "when the job listing has ect_suitable job role" do
        let(:job_roles) { %w[teacher ect_suitable] }

        it "does not set ect_suitable in the job_roles" do
          expect(subject.criteria[:job_roles]).to eq(%w[teacher])
        end
      end

      context "when the job listing has teaching_assistant or education_support as job role" do
        let(:job_roles) { %w[teaching_assistant send_responsible] }

        it "sets send_responsible in the job_roles" do
          expect(subject.criteria[:job_roles]).to eq(%w[teaching_assistant send_responsible])
        end
      end

      context "when the job listing has not teaching_assistant or education_support as job role" do
        let(:job_roles) { %w[teacher send_responsible] }

        it "does not set send_responsible in the job_roles" do
          expect(subject.criteria[:job_roles]).to eq(%w[teacher])
        end
      end
    end

    describe "subjects" do
      context "when the job listing has teacher or middle_leader as job role" do
        let(:job_roles) { %w[teacher] }
        let(:subjects) { %w[Science] }

        it "sets the subjects from the job listing" do
          expect(subject.criteria[:subjects]).to eq(subjects)
        end
      end

      context "when the job listing has not teacher or middle_leader as job role" do
        let(:job_roles) { %w[senior_leader] }
        let(:subjects) { %w[Science] }

        it "does not set the subjects" do
          expect(subject.criteria[:subjects]).to be_nil
        end
      end
    end
  end
end
