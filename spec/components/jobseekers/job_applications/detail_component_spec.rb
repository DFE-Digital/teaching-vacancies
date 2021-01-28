require "rails_helper"

RSpec.describe Jobseekers::JobApplications::DetailComponent, type: :component do
  let(:detail) do
    create(:job_application_detail, details_type: "talents", data: { "name" => "John", "speciality" => "Strength" })
  end
  let(:info_to_display) do
    [
      { attribute: "name", title: "Full name" },
      { attribute: "speciality", title: "Superpower(s)" },
    ]
  end

  let!(:inline_component) do
    render_inline(described_class.new(detail: detail, detail_counter: 1, info_to_display: info_to_display))
  end

  it "renders the name" do
    expect(inline_component.css(".govuk-summary-list__row").first.to_html).to include("Full name")
    expect(inline_component.css(".govuk-summary-list__row").first.to_html).to include("John")
  end

  it "renders the speciality" do
    expect(inline_component.css(".govuk-summary-list__row").last.to_html).to include("Superpower(s)")
    expect(inline_component.css(".govuk-summary-list__row").last.to_html).to include("Strength")
  end

  it "renders the heading" do
    expect(inline_component.css(".govuk-heading-s").to_html).to include("Talent 1")
  end

  it "renders the edit link" do
    expect(inline_component.css(".govuk-link").to_html)
      .to include(Rails.application.routes.url_helpers.edit_jobseekers_job_application_build_detail_path(detail.job_application, :talents, detail))
  end

  it "renders the delete button" do
    expect(inline_component.css(".button_to").to_html)
      .to include(Rails.application.routes.url_helpers.jobseekers_job_application_build_detail_path(detail.job_application, :talents, detail))
  end
end
