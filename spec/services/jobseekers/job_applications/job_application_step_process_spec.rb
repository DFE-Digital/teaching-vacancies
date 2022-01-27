require "rails_helper"

RSpec.describe Jobseekers::JobApplications::JobApplicationStepProcess do
  subject { described_class.new(current_step, job_application: job_application) }

  let(:current_step) { :personal_details }

  let(:job_application) { build_stubbed(:job_application, vacancy: vacancy) }

  describe "#step_groups" do
    let(:all_possible_step_groups) do
      %i[
        personal_details professional_status qualifications employment_history personal_statement
        references equal_opportunities ask_for_support declarations review
      ]
    end

    context "when vacancy job role is teacher" do
      let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[teacher]) }

      it "has the expected step groups" do
        expect(subject.step_groups.keys).to eq(all_possible_step_groups)
      end
    end

    context "when vacancy job role is education_support" do
      let(:vacancy) { build_stubbed(:vacancy, job_roles: %w[education_support]) }

      it "has the expected step groups" do
        expect(subject.steps).to eq(all_possible_step_groups - %i[professional_status])
      end
    end
  end
end
