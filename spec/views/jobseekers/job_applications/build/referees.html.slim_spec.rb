require "rails_helper"

RSpec.describe "jobseekers/job_applications/build/referees" do
  let(:job_application) do
    build_stubbed(:job_application,
                  referees: [referee])
  end
  let(:content) { "Current or most recent" }

  before do
    allow(view).to receive_messages(job_application: job_application,
                                    redirect_to_review?: false,
                                    vacancy: job_application.vacancy, back_path: "/")
    assign :form, Jobseekers::JobApplication::RefereesForm.new

    render
  end

  context "without a most recent flag" do
    let(:referee) { build_stubbed(:referee, is_most_recent_employer: nil) }

    it "doesnt show current text" do
      expect(rendered).to have_no_content(content)
    end
  end

  context "with a most recent flag" do
    let(:referee) { build_stubbed(:referee, is_most_recent_employer: true) }

    it "shows current text" do
      expect(rendered).to have_content(content)
    end
  end
end
