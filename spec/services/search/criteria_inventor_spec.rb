require "rails_helper"

RSpec.describe Search::CriteriaInventor do
  subject { described_class.new(vacancy) }

  let(:postcode) { "ab12 3cd" }
  let(:phases) { %w[secondary] }
  let(:school) { create(:school, postcode: postcode) }
  let(:working_patterns) { %w[full_time part_time] }
  let(:subjects) { %w[English Maths] }
  let(:job_title) { "A wonderful job" }
  let(:job_roles) { %w[teacher teaching_assistant administration_hr_data_and_finance] }
  let(:associated_orgs) { [school] }
  let(:vacancy) do
    create(:vacancy, organisations: associated_orgs,
                     working_patterns: working_patterns,
                     subjects: subjects,
                     job_title: job_title,
                     job_roles: job_roles,
                     phases: phases)
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
        let(:local_authority) { create(:local_authority) }

        it "sets the location to the local authority of the first school" do
          expect(subject.criteria[:location]).to eq(local_authority.read_attribute(:name))
        end

        it "sets the radius to 25" do
          expect(subject.criteria[:radius]).to eq("25")
        end
      end

      context "when the vacancy is at the central office of a trust" do
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
        expect(subject.criteria[:phases]).to eq(phases)
      end
    end

    describe "teaching_job_roles" do
      it "sets the job_roles with the job roles of the vacancy" do
        expect(subject.criteria[:teaching_job_roles]).to eq(["teacher"])
      end
    end

    describe "support_job_roles" do
      it "sets the job_roles with the job roles of the vacancy" do
        expect(subject.criteria[:support_job_roles]).to eq(%w[teaching_assistant administration_hr_data_and_finance])
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

      context "when the job listing's job role is neither teacher or middle_leader" do
        let(:job_roles) { %w[headteacher] }
        let(:subjects) { %w[Science] }

        it "does not set the subjects" do
          expect(subject.criteria[:subjects]).to be_nil
        end
      end
    end
  end
end
