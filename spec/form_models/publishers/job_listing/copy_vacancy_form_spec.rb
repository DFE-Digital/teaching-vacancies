require "rails_helper"

RSpec.describe Publishers::JobListing::CopyVacancyForm, type: :model do
  subject { described_class.new({ job_title: job_title }) }

  describe "validations" do
    describe "#job_title" do
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
          let(:job_title) { "Job &amp; another job" }

          it "does not validate presence of HTML tags" do
            subject.valid?
            expect(subject.errors.messages[:job_title]).to_not include(
              I18n.t("job_details_errors.job_title.invalid_characters"),
            )
          end
        end
      end
    end
  end
end
