require "rails_helper"

RSpec.describe JobDetailsForm, type: :model do
  context "validations" do
    describe "#suitable_for_nqt" do
      let(:subject) { JobDetailsForm.new(suitable_for_nqt: nil) }

      it "requests an entry in the field" do
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:suitable_for_nqt][0])
          .to eq("Please indicate whether or not the job is suitable for NQTs")
      end
    end

    describe "#working_patterns" do
      let(:subject) { JobDetailsForm.new(working_patterns: nil) }

      it "requests an entry in the field" do
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:working_patterns][0]).to eq("Select a working pattern")
      end
    end

    describe "#job_title" do
      let(:subject) { JobDetailsForm.new(job_title: job_title) }

      context "when title is blank" do
        let(:job_title) { nil }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title][0]).to eq("Enter a job title")
        end
      end

      context "when title is too short" do
        let(:job_title) { "aa" }

        it "validates minimum length" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title][0])
            .to eq(I18n.t("job_details_errors.job_title.too_short", count: 4))
        end
      end

      context "when title is too long" do
        let(:job_title) { "Long title" * 100 }

        it "validates max length" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title][0])
            .to eq(I18n.t("job_details_errors.job_title.too_long", count: 100))
        end
      end

      context "when title contains HTML tags" do
        let(:job_title) { "Title with <p>tags</p>" }

        it "validates presence of HTML tags" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title]).to include(
            I18n.t("job_details_errors.job_title.invalid_characters"),
          )
        end
      end

      context "when title does not contain HTML tags" do
        context "job title contains &" do
          let(:job_title) { "Job & another job" }

          it "does not validate presence of HTML tags" do
            expect(subject.errors.messages[:job_title]).to_not include(
              I18n.t("job_details_errors.job_title.invalid_characters"),
            )
          end
        end
      end
    end
  end

  context "when all attributes are valid" do
    it "a JobDetailsForm can be converted to a vacancy" do
      job_details_form = JobDetailsForm.new(state: "create", job_title: "English Teacher",
                                            job_roles: [:teacher], suitable_for_nqt: "no",
                                            working_patterns: %w[full_time], subjects: %w[Maths])

      expect(job_details_form.valid?).to be true
      expect(job_details_form.vacancy.job_title).to eq("English Teacher")
      expect(job_details_form.vacancy.job_roles).to eq(%w[teacher])
      expect(job_details_form.vacancy.suitable_for_nqt).to eq("no")
      expect(job_details_form.vacancy.working_patterns).to eq(%w[full_time])
      expect(job_details_form.vacancy.subjects).to include("Maths")
    end
  end
end
