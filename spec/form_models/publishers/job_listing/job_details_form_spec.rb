require "rails_helper"

RSpec.describe Publishers::JobListing::JobDetailsForm, type: :model do
  subject { described_class.new(params) }

  context "validations" do
    describe "#suitable_for_nqt" do
      context "when it is blank" do
        let(:params) { { suitable_for_nqt: nil } }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:suitable_for_nqt][0])
            .to eq("Please indicate whether or not the job is suitable for NQTs")
        end
      end
    end

    describe "#working_patterns" do
      context "when it is blank" do
        let(:params) { { working_patterns: nil } }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:working_patterns][0]).to eq("Select a working pattern")
        end
      end
    end

    describe "#job_title" do
      context "when title is blank" do
        let(:params) { { job_title: nil } }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title][0]).to eq("Enter a job title")
        end
      end

      context "when title is too short" do
        let(:params) { { job_title: "aa" } }

        it "validates minimum length" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title][0])
            .to eq(I18n.t("job_details_errors.job_title.too_short", count: 4))
        end
      end

      context "when title is too long" do
        let(:params) { { job_title: "aaaa" * 100 } }

        it "validates maximum length" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title][0])
            .to eq(I18n.t("job_details_errors.job_title.too_long", count: 100))
        end
      end

      context "when title contains HTML tags" do
        let(:params) { { job_title: "Title with <p>tags</p>" } }

        it "validates presence of HTML tags" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_title]).to include(
            I18n.t("job_details_errors.job_title.invalid_characters"),
          )
        end
      end

      context "when title does not contain HTML tags" do
        context "job title contains &" do
          let(:params) { { job_title: "Job & another job" } }

          it "does not validate presence of HTML tags" do
            expect(subject.errors.messages[:job_title]).to_not include(
              I18n.t("job_details_errors.job_title.invalid_characters"),
            )
          end
        end
      end
    end
  end

  describe "#contract_type" do
    context "when contract_type is blank" do
      let(:params) { { contract_type: "" } }

      it "requests to select one of the options" do
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:contract_type][0]).to eq(I18n.t("job_details_errors.contract_type.inclusion"))
      end
    end

    context "when fixed_term and empty contract_type_duration" do
      let(:params) { { contract_type: "fixed_term", contract_type_duration: "" } }

      it "validates contract_type_duration presence" do
        expect(subject.valid?).to be false
        expect(subject.errors.messages[:contract_type_duration][0]).to eq(I18n.t("job_details_errors.contract_type_duration.blank"))
      end
    end
  end

  context "when all attributes are valid" do
    let(:params) do
      {
        state: "create", job_title: "English Teacher",
        job_roles: [:teacher], suitable_for_nqt: "no",
        working_patterns: %w[full_time], subjects: %w[Maths],
        contract_type: :permanent
      }
    end
    it "a JobDetailsForm can be converted to a vacancy" do
      expect(subject.valid?).to be true
      expect(subject.vacancy.job_title).to eq("English Teacher")
      expect(subject.vacancy.job_roles).to eq(%w[teacher])
      expect(subject.vacancy.suitable_for_nqt).to eq("no")
      expect(subject.vacancy.working_patterns).to eq(%w[full_time])
      expect(subject.vacancy.subjects).to include("Maths")
      expect(subject.vacancy.contract_type).to eq("permanent")
    end
  end
end
