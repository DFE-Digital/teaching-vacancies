require "rails_helper"

RSpec.describe JobPreferences::JobScope do
  subject(:job_scope) { described_class.new(original_scope, job_preferences) }

  let(:original_scope) { Vacancy.live }

  let!(:vacancy1) do
    create(:vacancy,
           :published,
           job_roles: ["teacher"],
           phases: %w[primary secondary],
           key_stages: nil,
           subjects: %w[Spanish French],
           working_patterns: %w[part_time])
  end

  let!(:vacancy2) do
    create(:vacancy,
           :published,
           job_roles: ["teaching_assistant"],
           phases: %w[primary secondary],
           key_stages: %w[ks1],
           subjects: %w[Mathematics],
           working_patterns: %w[part_time])
  end

  let!(:vacancy3) do
    create(:vacancy,
           :published,
           job_roles: ["headteacher"],
           phases: %w[primary],
           key_stages: %w[ks2],
           subjects: [],
           working_patterns: %w[full_time])
  end

  let!(:vacancy4) do
    create(:vacancy,
           :published,
           job_roles: ["head_of_year_or_phase"],
           phases: %w[secondary],
           key_stages: %w[ks1 ks2],
           subjects: %w[Mathematics French Spanish],
           working_patterns: %w[part_time full_time])
  end

  let(:job_preferences) do
    build_stubbed(:job_preferences,
                  roles: %w[teacher teaching_assistant head_of_year_or_phase headteacher],
                  phases: %w[primary secondary],
                  working_patterns: %w[part_time full_time],
                  key_stages: %w[ks1 ks2])
  end

  describe "roles scope" do
    let(:jobseeker_roles) { %w[teacher head_of_year_or_phase] }

    before { job_preferences.roles = jobseeker_roles }

    it "returns vacancies with a role matching any of the jobseeker roles" do
      expect(job_scope.call).to contain_exactly(vacancy1, vacancy4)
    end

    context "with jobseeker roles that don't match any vacancy roles" do
      let(:jobseeker_roles) { %w[sendco] }

      it "returns no vacancies" do
        expect(job_scope.call).to be_empty
      end
    end

    context "with jobseeker without roles" do
      let(:jobseeker_roles) { [] }

      it "returns no vacancies" do
        expect(job_scope.call).to be_empty
      end
    end
  end

  describe "phases scope" do
    before { job_preferences.phases = jobseeker_phases }

    context "with all jobseeker phases matching vacancy phases" do
      let(:jobseeker_phases) { %w[primary secondary] }

      it "returns any vacancies with a phase matching the jobseeker phases" do
        expect(job_scope.call).to contain_exactly(vacancy1, vacancy2, vacancy3, vacancy4)
      end
    end

    context "with some of the jobseeker phases matching vacancy phases" do
      let(:jobseeker_phases) { %w[primary middle] }

      it "returns any vacancies with all their phases included by the jobseeker phases" do
        expect(job_scope.call).to contain_exactly(vacancy3)
      end
    end

    context "with no jobseeker phases matching the vacancy phases" do
      let(:jobseeker_phases) { %w[middle] }

      it "returns no vacancies" do
        expect(job_scope.call).to be_empty
      end
    end
  end

  describe "key stages scope" do
    before { job_preferences.key_stages = jobseeker_key_stages }

    context "with all jobseeker key stages matching vacancy key stages" do
      let(:jobseeker_key_stages) { %w[ks1 ks2] }

      it "returns any vacancies without any key stages or with all their key stages included in the jobseeker key stages" do
        expect(job_scope.call).to contain_exactly(vacancy1, vacancy2, vacancy3, vacancy4)
      end
    end

    context "with some of the jobseeker key stages matching vacancy key stages" do
      let(:jobseeker_key_stages) { %w[ks1 ks3] }

      it "returns any vacancies without any key stages or with all their key stages included in the jobseeker key stages" do
        expect(job_scope.call).to contain_exactly(vacancy1, vacancy2)
      end
    end

    context "with no jobseeker key stages matching the vacancy key stages" do
      let(:jobseeker_key_stages) { %w[ks3] }

      it "only returns the vacancy without any key stages" do
        expect(job_scope.call).to contain_exactly(vacancy1)
      end
    end
  end

  describe "subjects scope" do
    before { job_preferences.subjects = jobseeker_subjects }

    context "without any jobseeker subject" do
      let(:jobseeker_subjects) { [] }

      it "returns all the vacancies" do
        expect(job_scope.call).to contain_exactly(vacancy1, vacancy2, vacancy3, vacancy4)
      end
    end

    context "with jobseeker subjects matching vacancy subjects" do
      let(:jobseeker_subjects) { %w[French Spanish] }

      it "returns vacancies without subjects or with any of their subjects included in the jobseeker subjects" do
        expect(job_scope.call).to contain_exactly(vacancy1, vacancy3, vacancy4)
      end
    end

    context "with no jobseeker subjects matching the vacancy subjects" do
      let(:jobseeker_subjects) { %w[History] }

      it "only returns the vacancy without any subjects" do
        expect(job_scope.call).to contain_exactly(vacancy3)
      end
    end
  end

  describe "working patterns scope" do
    before { job_preferences.working_patterns = jobseeker_working_patterns }

    context "without any jobseeker working_patterns" do
      let(:jobseeker_working_patterns) { [] }

      it "does not return any vacancies" do
        expect(job_scope.call).to be_empty
      end
    end

    context "with jobseeker working patterns matching vacancy working patterns" do
      let(:jobseeker_working_patterns) { %w[part_time] }

      it "returns vacancies with any of their working patterns included in the jobseeker working patterns" do
        expect(job_scope.call).to contain_exactly(vacancy1, vacancy2, vacancy4)
      end
    end
  end
end
