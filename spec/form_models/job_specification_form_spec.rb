require "rails_helper"

RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  context "validations" do
    describe "#suitable_for_nqt" do
      let(:job_specification) { JobSpecificationForm.new(suitable_for_nqt: nil) }

      it "requests an entry in the field" do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:suitable_for_nqt][0])
          .to eq("Please indicate whether or not the job is suitable for NQTs")
      end
    end

    describe "#working_patterns" do
      let(:job_specification) { JobSpecificationForm.new(working_patterns: nil) }

      it "requests an entry in the field" do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:working_patterns][0])
          .to eq("Select a working pattern")
      end
    end

    describe "#job_title" do
      let(:job_specification) { JobSpecificationForm.new(job_title: job_title) }

      context "when title is blank" do
        let(:job_title) { nil }

        it "requests an entry in the field" do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq("Enter a job title")
        end
      end

      context "when title is too short" do
        let(:job_title) { "aa" }

        it "validates minimum length" do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq(I18n.t("activemodel.errors.models.job_specification_form.attributes.job_title.too_short", count: 4))
        end
      end

      context "when title is too long" do
        let(:job_title) { "Long title" * 100 }

        it "validates max length" do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title][0])
            .to eq(I18n.t("activemodel.errors.models.job_specification_form.attributes.job_title.too_long", count: 100))
        end
      end

      context "when title contains HTML tags" do
        let(:job_title) { "Title with <p>tags</p>" }

        it "validates presence of HTML tags" do
          expect(job_specification.valid?).to be false
          expect(job_specification.errors.messages[:job_title]).to include(
            I18n.t("activemodel.errors.models.job_specification_form.attributes.job_title.invalid_characters"),
          )
        end
      end

      context "when title does not contain HTML tags" do
        context "job title contains &" do
          let(:job_title) { "Job & another job" }

          it "does not validate presence of HTML tags" do
            expect(job_specification.errors.messages[:job_title]).to_not include(
              I18n.t("activemodel.errors.models.job_specification_form.attributes.job_title.invalid_characters"),
            )
          end
        end
      end
    end
  end

  context "when all attributes are valid" do
    it "a JobSpecificationForm can be converted to a vacancy" do
      job_specification_form = JobSpecificationForm.new(state: "create", job_title: "English Teacher",
                                                        job_roles: [:teacher],
                                                        suitable_for_nqt: "no",
                                                        working_patterns: %w[full_time],
                                                        subjects: %w[Maths])

      expect(job_specification_form.valid?).to be true
      expect(job_specification_form.vacancy.job_title).to eq("English Teacher")
      expect(job_specification_form.vacancy.job_roles).to eq(%w[teacher])
      expect(job_specification_form.vacancy.suitable_for_nqt).to eq("no")
      expect(job_specification_form.vacancy.working_patterns).to eq(%w[full_time])
      expect(job_specification_form.vacancy.subjects).to include("Maths")
    end
  end
end
