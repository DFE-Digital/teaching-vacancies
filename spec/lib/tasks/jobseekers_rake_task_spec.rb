require "rails_helper"

RSpec.describe "jobseekers:remove_profile_training_and_cpds" do
  include_context "rake"

  let!(:profile_training_and_cpd) { create(:training_and_cpd, jobseeker_profile: create(:jobseeker_profile)) }
  let!(:job_application_training_and_cpd) { create(:training_and_cpd, job_application: create(:job_application)) }

  it "deletes only profile-owned Training and CPD records" do
    expect { subject.execute }
      .to change(TrainingAndCpd, :count).from(2).to(1)

    expect(TrainingAndCpd.exists?(profile_training_and_cpd.id)).to be(false)
    expect(TrainingAndCpd.exists?(job_application_training_and_cpd.id)).to be(true)
  end
end
