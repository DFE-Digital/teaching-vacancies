require "rails_helper"

RSpec.describe Jobseekers::Qualifications::QualificationForm do
  describe "validations" do
    let(:form) do
      described_class.new(
        category: "undergraduate",
        finished_studying: finished_studying,
        finished_studying_details: finished_studying_details,
        year: year,
        month: month,
      )
    end

    describe "#category" do
      let(:finished_studying) { true }
      let(:finished_studying_details) { nil }
      let(:year) { 2020 }
      let(:month) { 6 }

      context "when category is blank" do
        let(:form) { described_class.new(category: "") }

        it "is invalid" do
          expect(form).not_to be_valid
          expect(form.errors[:category]).to be_present
        end
      end
    end

    describe "#finished_studying_details" do
      let(:year) { nil }
      let(:month) { nil }

      context "when finished_studying is false" do
        let(:finished_studying) { false }

        context "when finished_studying_details is present" do
          let(:finished_studying_details) { "Current student" }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "when finished_studying_details is blank" do
          let(:finished_studying_details) { "" }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:finished_studying_details]).to be_present
          end
        end
      end

      context "when finished_studying is true" do
        let(:finished_studying) { true }
        let(:finished_studying_details) { "" }
        let(:year) { 2020 }

        it "is valid even if finished_studying_details is blank" do
          expect(form).to be_valid
        end
      end
    end

    describe "#year" do
      let(:finished_studying_details) { nil }
      let(:month) { nil }

      context "when finished_studying is true" do
        let(:finished_studying) { true }

        context "when year is in the future" do
          let(:year) { Time.current.year + 1 }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:year]).to be_present
          end
        end

        context "when year is in the past" do
          let(:year) { Time.current.year - 1 }

          it "is valid" do
            expect(form).to be_valid
          end
        end
      end

      context "when finished_studying is false" do
        let(:finished_studying) { false }
        let(:finished_studying_details) { "Current student" }
        let(:year) { nil }

        it "does not validate year" do
          expect(form).to be_valid
        end
      end
    end

    describe "#month" do
      let(:finished_studying_details) { nil }
      let(:year) { 2020 }

      context "when finished_studying is true" do
        let(:finished_studying) { true }

        context "when month is nil" do
          let(:month) { nil }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "when month is a valid month number" do
          let(:month) { 6 }

          it "is valid" do
            expect(form).to be_valid
          end
        end

        context "when month is less than 1" do
          let(:month) { 0 }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:month]).to be_present
          end
        end

        context "when month is greater than 12" do
          let(:month) { 13 }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:month]).to be_present
          end
        end

        context "when month is not an integer" do
          let(:month) { "June" }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:month]).to be_present
          end
        end
      end

      context "when finished_studying is false" do
        let(:finished_studying) { false }
        let(:finished_studying_details) { "Current student" }

        context "when month is provided" do
          let(:month) { 6 }

          it "does not validate month" do
            expect(form).to be_valid
          end
        end
      end
    end
  end
end
