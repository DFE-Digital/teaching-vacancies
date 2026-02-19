require "rails_helper"

RSpec.describe Jobseekers::JobApplications::PrefillJobApplicationFromJobseekerProfile do
  let(:jobseeker) { create(:jobseeker) }
  let(:new_vacancy) { create(:vacancy) }
  let!(:jobseeker_profile) do
    create(:jobseeker_profile, :completed,
           jobseeker: jobseeker,
           job_preferences: build(:job_preferences, working_patterns: build_stubbed(:job_preferences).working_patterns + %w[term_time flexible]))
  end
  let(:new_job_application) { jobseeker.job_applications.create(vacancy: new_vacancy) }

  subject { described_class.new(jobseeker, new_job_application).call }

  it "creates a new draft job application for the new vacancy" do
    expect { subject }.to change { jobseeker.job_applications.draft.count }.by(1)
    expect(subject.vacancy).to eq(new_vacancy)
  end

  it "copies qualifications from jobseeker profile" do
    attributes_to_copy = %i[category finished_studying finished_studying_details grade institution name subject year]

    expect(subject.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
      .to eq(jobseeker_profile.qualifications.map { |qualification| qualification.slice(*attributes_to_copy) })
  end

  it "removes legacy working patterns" do
    expect(subject.working_patterns).to eq(%w[full_time part_time job_share])
  end

  it "adds qualifications to in progress steps" do
    expect(subject.in_progress_steps).to include("qualifications")
  end

  it "copies employments from jobseeker profile" do
    attributes_to_copy = %i[organisation job_title subjects is_current_role main_duties started_on ended_on]

    expect(subject.employments.map { |employment| employment.slice(*attributes_to_copy) })
      .to eq(jobseeker_profile.employments.map { |employment| employment.slice(*attributes_to_copy) })
  end

  it "adds employment history to in progress steps" do
    expect(subject.in_progress_steps).to include("employment_history")
  end

  it "copies training and cpds from jobseeker profile" do
    attributes_to_copy = %i[name provider grade year_awarded]

    expect(subject.training_and_cpds.map { |training| training.slice(*attributes_to_copy) })
      .to eq(jobseeker_profile.training_and_cpds.map { |training| training.slice(*attributes_to_copy) })
  end

  it "adds training and cpds to in progress steps" do
    expect(subject.in_progress_steps).to include("training_and_cpds")
  end

  it "copies professional body memberships from jobseeker profile" do
    attributes_to_copy = %i[name membership_type membership_number year_membership_obtained]

    expect(subject.professional_body_memberships.map { |professional_body_membership| professional_body_membership.slice(*attributes_to_copy) })
      .to eq(jobseeker_profile.professional_body_memberships.map { |professional_body_membership| professional_body_membership.slice(*attributes_to_copy) })
  end
end
