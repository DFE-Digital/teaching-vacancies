require "rails_helper"

RSpec.describe Jobseekers::JobApplications::DetailComponent, type: :component do
  let(:detail) do
    create(
      :job_application_detail,
      details_type: "references",
      data: { "name" => "John", "speciality" => "Strength", "nice_date(1i)" => "2021", "nice_date(2i)" => "01", "nice_date(3i)" => "01" },
    )
  end
  let(:info_to_display) do
    [
      { attribute: "name", title: "Full name" },
      { attribute: "speciality", title: "Superpower(s)" },
      { attribute: "nice_date", title: "Nice date", date: true },
    ]
  end

  let!(:inline_component) do
    render_inline(described_class.new(detail: detail, title_attribute: "name", info_to_display: info_to_display))
  end

  it "renders the name" do
    expect(inline_component.css(".govuk-summary-list__row")[0].to_html).to include("Full name")
    expect(inline_component.css(".govuk-summary-list__row")[0].to_html).to include("John")
  end

  it "renders the speciality" do
    expect(inline_component.css(".govuk-summary-list__row")[1].to_html).to include("Superpower(s)")
    expect(inline_component.css(".govuk-summary-list__row")[1].to_html).to include("Strength")
  end

  it "renders the date" do
    expect(inline_component.css(".govuk-summary-list__row")[2].to_html).to include("Nice date")
    expect(inline_component.css(".govuk-summary-list__row")[2].to_html).to include(Date.new(2021, 0o1, 0o1).to_s)
  end

  it "renders the title" do
    expect(inline_component.css(".govuk-heading-s").to_html).to include("John")
  end

  it "renders the edit link" do
    expect(inline_component.css(".govuk-link").to_html)
      .to include(Rails.application.routes.url_helpers.edit_jobseekers_job_application_build_detail_path(detail.job_application, :references, detail))
  end

  it "renders the delete button" do
    expect(inline_component.css(".button_to").to_html)
      .to include(Rails.application.routes.url_helpers.jobseekers_job_application_build_detail_path(detail.job_application, :references, detail))
  end
end
