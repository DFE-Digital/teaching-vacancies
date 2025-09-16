require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe InterviewDatetimeForm, type: :model do
      let(:form) { described_class.new(interview_date:, interview_time:, job_application:) }

      let(:job_application) { build_stubbed(:job_application, :status_interviewing) }
      let(:interview_date) { { 1 => 2025, 2 => 9, 3 => 1 } }
      let(:interview_time) { "10:45am" }

      describe ".interview_date" do
        it { expect(form.interview_date).to eq(Date.new(2025, 9, 1)) }
      end

      describe ".interview_time" do
        it { expect(form.interview_time).to eq(Time.zone.parse("10:45")) }
        it { expect(form.interview_time.to_s).to eq("10:45am") }
      end

      describe ".interviewing_at" do
        subject { form.interviewing_at }

        context "with valid params" do
          it { is_expected.to eq(Time.zone.local(2025, 9, 1, 10, 45)) }
        end

        context "with invalid params" do
          let(:interview_time) { "aastesth" }

          it { expect { form.interviewing_at }.to raise_error(NoMethodError) }
        end
      end

      describe "validations" do
        before { form.valid? }

        context "with bad date" do
          let(:interview_date) { { 1 => "nth", 2 => 4 } }

          it { expect(form.errors.details).to include(interview_date: [{ error: :invalid }]) }
        end

        context "with missing date" do
          let(:interview_date) { nil }

          it { expect(form.errors.details).to include(interview_date: [{ error: :blank }]) }
        end

        context "with bad time" do
          let(:interview_time) { "badtime" }

          it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
        end

        context "with missing time" do
          let(:interview_time) { nil }

          it { expect(form.errors.details).to include(interview_time: [{ error: :blank }]) }
        end

        context "with job application in wrong state" do
          let(:job_application) { build_stubbed(:job_application, :status_submitted) }

          it { expect(form.errors.details).to include(job_application: [{ error: :invalid }]) }
        end
      end
    end
  end
end
