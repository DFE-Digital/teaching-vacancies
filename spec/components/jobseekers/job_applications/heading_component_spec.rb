require "rails_helper"

RSpec.describe Jobseekers::JobApplications::HeadingComponent, type: :component do
  let(:school) { build_stubbed(:school, name: "Test school") }
  let(:vacancy) do
    build_stubbed(:vacancy, :at_one_school, :published_slugged, job_title: "Test job",
                                                                organisation_vacancies_attributes: [{ organisation: school }])
  end
  let(:back_path) { "/link-to-back-path" }

  let!(:inline_component) { render_inline(described_class.new(vacancy: vacancy, back_path: back_path)) }

  it "renders the caption" do
    expect(inline_component.css(".govuk-caption-l").to_html).to include("Test job at Test school")
  end

  it "renders the heading" do
    expect(inline_component.css(".govuk-heading-xl").to_html).to include("Application")
  end

  it "renders the back link" do
    expect(inline_component.css(".govuk-back-link").to_html)
      .to eq("<a class=\"govuk-back-link govuk-!-margin-top-3\" href=\"/link-to-back-path\">Back</a>")
  end
end
