require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe InterviewDatetimeForm, type: :model do
      let(:form) { described_class.new(interview_date:, interview_time:, job_applications:) }

      let(:job_applications) { build_stubbed_list(:job_application, 1, :status_interviewing) }
      let(:interview_date) { { 1 => 2025, 2 => 9, 3 => 1 } }
      let(:interview_time) { "10:45am" }

      describe ".attributes" do
        subject { form.attributes }

        context "when validate_all_attributes is truthy" do
          before { form.validate_all_attributes = true }

          it { is_expected.to include(interviewing_at: Time.zone.local(2025, 9, 1, 10, 45)) }
        end

        context "when validate_all_attributes is falsey" do
          it { is_expected.to be_empty }
        end
      end

      describe ".interview_date" do
        it { expect(form.interview_date).to eq(Date.new(2025, 9, 1)) }
      end

      describe ".interview_time" do
        it { expect(form.interview_time).to eq(Time.zone.parse("10:45")) }
        it { expect(form.interview_time.to_s).to eq("10:45am") }

        context "with 2-digit hour and colon (10:30)" do
          let(:interview_time) { "10:30" }

          it { expect(form.interview_time).to eq(Time.zone.parse("10:30")) }
        end

        context "with 2-digit hour and pm (10:30pm)" do
          let(:interview_time) { "10:30pm" }

          it { expect(form.interview_time).to eq(Time.zone.parse("22:30")) }
        end

        context "with 2-digit hour without separator (1030)" do
          let(:interview_time) { "1030" }

          it { expect(form.interview_time).to eq("1030") }
        end
      end

      describe ".interviewing_at" do
        subject { form.interviewing_at }

        context "with valid params" do
          it { is_expected.to eq(Time.zone.local(2025, 9, 1, 10, 45)) }
        end

        context "with invalid params" do
          let(:interview_time) { "aastesth" }

          it { expect { form.interviewing_at }.to raise_error(ArgumentError, "invalid interview_date or interview_time") }
        end
      end

      describe "validations" do
        context "when validating all" do
          before do
            form.validate_all_attributes = true
            form.valid?
          end

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

          context "with time using a dot separator (2.30pm)" do
            let(:interview_time) { "2.30pm" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with time using a comma separator (2,30pm)" do
            let(:interview_time) { "2,30pm" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with time missing separator (230pm)" do
            let(:interview_time) { "230pm" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with invalid am/pm suffix (230em)" do
            let(:interview_time) { "230em" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with time using a space separator (2 30pm)" do
            let(:interview_time) { "2 30pm" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with valid time (2:30pm)" do
            let(:interview_time) { "2:30pm" }

            it { expect(form.errors.details).not_to include(:interview_time) }
          end

          context "with space between time and am/pm (2:30 pm)" do
            let(:interview_time) { "2:30 pm" }

            it { expect(form.errors.details).not_to include(:interview_time) }
          end

          context "with uppercase am/pm (2:30 PM)" do
            let(:interview_time) { "2:30 PM" }

            it { expect(form.errors.details).not_to include(:interview_time) }
          end

          context "with 24h time (14:30)" do
            let(:interview_time) { "14:30" }

            it { expect(form.errors.details).not_to include(:interview_time) }
          end

          context "with 24h time using space separator (14 30)" do
            let(:interview_time) { "14 30" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with 24h time without separator (1430)" do
            let(:interview_time) { "1430" }

            it { expect(form.errors.details).to include(interview_time: [{ error: :invalid }]) }
          end

          context "with missing time" do
            let(:interview_time) { nil }

            it { expect(form.errors.details).to include(interview_time: [{ error: :blank }]) }
          end

          context "with job application in wrong state" do
            let(:job_applications) { build_stubbed_list(:job_application, 1, :status_submitted) }

            it { expect(form.errors.details).to include(job_application: [{ error: :invalid }]) }
          end
        end

        context "when validating only job_application" do
          before do
            form.validate_all_attributes = nil
            form.valid?
          end

          context "with missing date" do
            let(:interview_date) { nil }

            it { expect(form.errors.details).to be_empty }
          end

          context "with missing time" do
            let(:interview_time) { nil }

            it { expect(form.errors.details).to be_empty }
          end

          context "with job application in wrong state" do
            let(:job_applications) { build_stubbed_list(:job_application, 1, :status_submitted) }

            it { expect(form.errors.details).to include(job_application: [{ error: :invalid }]) }
          end
        end
      end
    end
  end
end
