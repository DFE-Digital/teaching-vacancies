require "rails_helper"

RSpec.describe Publishers::ExportVacancyToCsv do
  subject { described_class.call(vacancy, vacancy.job_applications.partition { |ja| %w[withdrawn unsuccessful].exclude?(ja.status) }.map(&:count)) }

  let(:school) { build_stubbed(:school) }
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:job_title) { "Example job title without commas so we can ignore whether to expect this to be wrapped in quotes" }
  let(:vacancy) do
    build_stubbed(:vacancy, job_title: job_title,
                            job_applications:
                                  [
                                    build_stubbed(:job_application, :status_reviewed, jobseeker: jobseeker),
                                    build_stubbed(:job_application, :status_submitted, jobseeker: jobseeker),
                                    build_stubbed(:job_application, :status_shortlisted, jobseeker: jobseeker),
                                    build_stubbed(:job_application, :status_unsuccessful, jobseeker: jobseeker),
                                    build_stubbed(:job_application, :status_withdrawn, jobseeker: jobseeker),
                                  ],
                            organisations: [school], enable_job_applications: can_receive_job_applications?)
  end

  describe "#call" do
    context "when the vacancy cannot receive job applications" do
      let(:can_receive_job_applications?) { false }

      it "returns a CSV of the vacancy views and saves" do
        expect(subject).to eq(["Organisation,Job title",
                               "#{school.name},#{job_title}\n"].join("\n"))
      end
    end

    context "when the vacancy can receive job applications" do
      let(:can_receive_job_applications?) { true }

      it "returns a CSV of the vacancy statistics, excluding draft applications" do
        expect(subject).to eq(["Organisation,Job title,Total applications,Shortlisted or sucessful applications,Rejected or Withdrawn applications",
                               "#{school.name},#{job_title},5,3,2\n"].join("\n"))
      end
    end
  end
end
