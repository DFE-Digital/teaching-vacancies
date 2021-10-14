require "rails_helper"

RSpec.describe Jobseekers::SimilarJobComponent, type: :component do
  let(:school) { create(:school) }
  let(:vacancy) { create(:vacancy, :at_one_school, organisations: [school]) }

  before do
    render_inline(described_class.new(vacancy: vacancy))
  end

  it "renders the similar job link" do
    expect(rendered_component).to include(
      '<a class="govuk-link view-similar-job-gtm" '\
      "href=\"#{Rails.application.routes.url_helpers.job_path(vacancy)}\">#{vacancy.job_title}</a>",
    )
  end

  it "renders the vacancy parent organisation name" do
    expect(rendered_component).to include(school.name)
  end

  it "renders the vacancy parent organisation address" do
    expect(rendered_component).to include(full_address(school))
  end
end
