require "rails_helper"

RSpec.describe Publishers::JobListing::JobSummaryForm, type: :model do
  subject { described_class.new(params) }

  context "validations" do
    describe "#job_summary" do
      context "when job_summary is blank" do
        let(:params) { { job_summary: "" } }

        it "requests an entry in the field" do
          expect(subject.valid?).to be false
          expect(subject.errors.messages[:job_summary]).to include(I18n.t("job_summary_errors.job_summary.blank"))
        end
      end
    end

    describe "#about_school" do
      context "when about school is blank" do
        context "when vacancy job_location is at_one_school" do
          let(:params) { { about_school: "", job_location: "at_one_school" } }

          it "requests the user to complete the about school field" do
            expect(subject.valid?).to be false
            expect(subject.errors.messages[:about_school].first)
              .to eq(I18n.t("job_summary_errors.about_school.blank", organisation: "school"))
          end
        end

        context "when vacancy job_location is central_office" do
          let(:params) { { about_school: "", job_location: "central_office" } }

          it "requests the user to complete the about trust field" do
            expect(subject.valid?).to be false
            expect(subject.errors.messages[:about_school].first)
              .to eq(I18n.t("job_summary_errors.about_school.blank", organisation: "trust"))
          end
        end

        context "when vacancy job_location is at_multiple_schools" do
          let(:params) { { about_school: "", job_location: "at_multiple_schools" } }

          it "requests the user to complete the about schools field" do
            expect(subject.valid?).to be false
            expect(subject.errors.messages[:about_school].first)
              .to eq(I18n.t("job_summary_errors.about_school.blank", organisation: "schools"))
          end
        end
      end
    end
  end

  context "when all attributes are valid" do
    let(:params) { { state: "create", job_summary: "Summary about the job", about_school: "Description of the school" } }

    it "a JobSummaryForm can be converted to a vacancy" do
      expect(subject.valid?).to be true
      expect(subject.vacancy.job_summary).to eq("Summary about the job")
      expect(subject.vacancy.about_school).to eq("Description of the school")
    end
  end
end
