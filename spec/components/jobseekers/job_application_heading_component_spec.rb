require "rails_helper"

RSpec.describe Jobseekers::JobApplicationHeadingComponent, type: :component do
  let(:school) { build_stubbed(:school, name: "Test school") }
  let(:vacancy) do
    build_stubbed(:vacancy, :at_one_school, job_title: "Test job",
                                            organisation_vacancies_attributes: [{ organisation: school }])
  end

  before do
    render_inline(described_class.new(vacancy: vacancy))
  end

  it "renders the caption" do
    expect(rendered_component).to include("Test job at Test school")
  end

  it "renders the heading" do
    expect(rendered_component).to include("Application")
  end
end
