require "rails_helper"

RSpec.describe Resettable do
  context "inclusion" do
    let(:vacancy) { build(:vacancy) }

    it { expect(vacancy).to respond_to(:reset_dependent_fields) }
  end

  context "when changing education support" do
    subject(:update_education_support) { vacancy.update(job_roles: %w[education_support]) }

    let(:vacancy) { build(:vacancy, phases: %w[primary], job_roles: %w[teacher], key_stages: %w[ks1]) }
    let(:previous_key_stages) { vacancy.key_stages }

    it "resets key stages" do
      expect { update_education_support }
        .to change(vacancy, :key_stages)
        .from(previous_key_stages).to([])
    end
  end

  context "when changing education phases" do
    subject(:update_education_phases) { vacancy.update(phases: updated_phases) }

    let(:vacancy) { build(:vacancy, :secondary) }
    let(:previous_subjects) { vacancy.subjects }
    let(:previous_key_stages) { vacancy.key_stages }

    context "to primary school" do
      let(:updated_phases) { %w[primary] }

      it "resets subjects" do
        expect { update_education_phases }
          .to change(vacancy, :subjects)
          .from(previous_subjects).to([])
      end
    end

    context "to nursery" do
      let(:updated_phases) { %w[nursery] }

      it "resets key stages" do
        expect { update_education_phases }
          .to change(vacancy, :key_stages)
          .from(previous_key_stages).to(%w[early_years])
      end
    end
  end

  context "when changing job role" do
    subject(:update_job_role) { vacancy.update(job_roles: %w[education_support]) }

    let(:vacancy) { build(:vacancy, job_roles: %w[teacher]) }
    let(:previous_ect_status) { vacancy.ect_status }

    it "resets the ect status" do
      expect { update_job_role }
        .to change(vacancy, :ect_status)
        .from(previous_ect_status).to(nil)
    end
  end

  context "when changing additional documents" do
    let(:vacancy) { build(:vacancy, :with_supporting_documents) }
    let(:previous_supporting_documents) { vacancy.supporting_documents }
    let(:document) { double("ActiveRecordStorage", purge_later: nil) }

    before do
      allow(vacancy).to receive(:supporting_documents).and_return([document])
      vacancy.update!(include_additional_documents: false)
    end

    it "removes all previous supporting documents" do
      expect(vacancy.supporting_documents).to all(have_received(:purge_later))
    end
  end
end
