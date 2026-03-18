# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadableVacancyHelper do
  describe "#readable_working_patterns" do
    context "when is_job_share" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], is_job_share: true) }

      it "returns working patterns" do
        expect(vacancy_readable_working_patterns(vacancy)).to eq("Full time, part time (Can be done as a job share)")
      end
    end

    context "when is_job_share == false" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], is_job_share: false) }

      it "returns working patterns" do
        expect(vacancy_readable_working_patterns(vacancy)).to eq("Full time, part time")
      end
    end
  end

  describe "#readable_working_patterns_with_details" do
    let(:working_patterns) { %w[full_time part_time] }
    let(:working_patterns_details) { "Some details" }
    let(:vacancy) { build_stubbed(:vacancy, working_patterns:, working_patterns_details:, is_job_share: false) }

    it "returns the working with details" do
      expect(vacancy_readable_working_patterns_with_details(vacancy)).to eq("Full time, part time: Some details")
    end

    context "when there is no details" do
      let(:working_patterns_details) { "" }

      it "returns the working patterns" do
        expect(vacancy_readable_working_patterns_with_details(vacancy)).to eq("Full time, part time")
      end
    end
  end

  describe "#fixed_term_contract_duration" do
    let(:vacancy) do
      build_stubbed(:vacancy, contract_type: contract_type,
                              fixed_term_contract_duration: fixed_term_contract_duration,
                              is_parental_leave_cover: is_parental_leave_cover)
    end

    context "when permanent" do
      let(:contract_type) { :permanent }
      let(:fixed_term_contract_duration) { "" }
      let(:is_parental_leave_cover) { nil }

      it "returns Permanent" do
        expect(vacancy_contract_type_with_duration(vacancy)).to eq "Permanent"
      end
    end

    context "when fixed term" do
      let(:contract_type) { :fixed_term }
      let(:fixed_term_contract_duration) { "6 months" }

      context "when is_parental_leave_cover is false" do
        let(:is_parental_leave_cover) { false }

        it "returns Fixed term (duration)" do
          expect(vacancy_contract_type_with_duration(vacancy)).to eq "Fixed term - 6 months"
        end
      end

      context "when is_parental_leave_cover is true" do
        let(:is_parental_leave_cover) { true }

        it "returns Fixed term (duration)" do
          expect(vacancy_contract_type_with_duration(vacancy)).to eq "Fixed term - 6 months - Maternity or parental leave cover"
        end
      end
    end
  end

  describe "#readable_subjects" do
    let(:vacancy) { build_stubbed(:vacancy, subjects: %w[Acrobatics Tapestry]) }

    it "joins them correctly" do
      expect(vacancy_readable_subjects(vacancy)).to eq("Acrobatics, Tapestry")
    end

    context "when there are no subjects" do
      let(:vacancy) { build_stubbed(:vacancy, subjects: []) }

      it "returns empty string" do
        expect(vacancy_readable_subjects(vacancy)).to be_blank
      end
    end
  end

  describe "#readable_key_stages" do
    let(:vacancy) { build_stubbed(:vacancy, key_stages: %w[ks1 early_years]) }

    it "joins them correctly" do
      expect(vacancy_readable_key_stages(vacancy)).to eq("Key stage 1, Early years")
    end

    context "when there are no subjects" do
      let(:vacancy) { build_stubbed(:vacancy, key_stages: []) }

      it "returns empty string" do
        expect(vacancy_readable_key_stages(vacancy)).to be_blank
      end
    end
  end
end
