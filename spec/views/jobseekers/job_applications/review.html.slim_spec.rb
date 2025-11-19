require "rails_helper"

RSpec.describe "jobseekers/job_applications/review" do
  let(:jobseeker) { build_stubbed(:jobseeker) }
  let(:job_application) { build_stubbed(:job_application, :status_shortlisted, vacancy: vacancy, jobseeker: jobseeker) }

  before do
    allow(view).to receive_messages(vacancy: vacancy, current_jobseeker: jobseeker)
    assign :review_form, Jobseekers::JobApplication::ReviewForm.new
    assign :job_application, job_application

    render
  end

  context "with a vacancy from a trust" do
    let(:trust_name) { Faker::Educator.primary_school }
    let(:vacancy) { build_stubbed(:vacancy, organisations: build_stubbed_list(:trust, 1, name: trust_name)) }

    it "has MAT-specific content" do
      expect(rendered).to have_content("Do you have any family or close relationship(s) with people within the school, MAT or any governors or trustees at #{trust_name}?")
    end
  end

  context "with a vacancy from a school" do
    let(:school_name) { Faker::Educator.primary_school }
    let(:vacancy) { build_stubbed(:vacancy, organisations: build_stubbed_list(:school, 1, name: school_name)) }

    it "has content which doesnt mention a MAT" do
      expect(rendered).to have_content("Do you have any family or close relationship(s) with people within the school or any governors or trustees at #{school_name}?")
    end
  end
end
