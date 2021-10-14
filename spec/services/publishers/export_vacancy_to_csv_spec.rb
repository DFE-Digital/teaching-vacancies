require "rails_helper"

RSpec.describe Publishers::ExportVacancyToCsv do
  subject { described_class.new(vacancy, number_of_unique_views) }

  let(:school) { create(:school) }
  let(:jobseeker) { create(:jobseeker) }
  let(:job_title) { "Example job title without commas so we can ignore whether to expect this to be wrapped in quotes" }
  let(:vacancy) { create(:vacancy, job_title: job_title, organisations: [school]) }
  let(:number_of_unique_views) { 64 }
  let(:number_of_saves) { 1 }

  before do
    number_of_saves.times { create(:saved_job, vacancy: vacancy, jobseeker: jobseeker) }
    create(:job_application, :status_draft, vacancy: vacancy, jobseeker: jobseeker)
    create(:job_application, :status_reviewed, vacancy: vacancy, jobseeker: jobseeker)
    create(:job_application, :status_submitted, vacancy: vacancy, jobseeker: jobseeker)
    create(:job_application, :status_shortlisted, vacancy: vacancy, jobseeker: jobseeker)
    create(:job_application, :status_unsuccessful, vacancy: vacancy, jobseeker: jobseeker)
    create(:job_application, :status_withdrawn, vacancy: vacancy, jobseeker: jobseeker)
  end

  describe "#call" do
    before { allow(vacancy).to receive(:can_receive_job_applications?).and_return(can_receive_job_applications?) }

    context "when the vacancy cannot receive job applications" do
      let(:can_receive_job_applications?) { false }

      it "returns a CSV of the vacancy views and saves" do
        expect(subject.call).to eq(["Organisation,Job title,Views by jobseekers,Saves by jobseekers",
                                    "#{school.name},#{job_title},#{number_of_unique_views},#{number_of_saves}\n"].join("\n"))
      end
    end

    context "when the vacancy can receive job applications" do
      let(:can_receive_job_applications?) { true }

      it "returns a CSV of the vacancy statistics, excluding draft applications" do
        expect(subject.call).to eq(["Organisation,Job title,Views by jobseekers,Saves by jobseekers,Total applications,Unread applications,Shortlisted applications,Rejected applications,Withdrawn applications",
                                    "#{school.name},#{job_title},#{number_of_unique_views},#{number_of_saves},5,1,1,1,1\n"].join("\n"))
      end
    end
  end
end
