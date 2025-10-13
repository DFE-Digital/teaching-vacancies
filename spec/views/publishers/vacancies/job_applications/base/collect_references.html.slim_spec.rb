require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/base/collect_references" do
  let(:form) { Publishers::JobApplication::CollectReferencesForm.new }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:page) { Capybara.string(rendered) }

  before do
    assign :form, form
    assign :vacancy, vacancy
    allow(view).to receive_messages(wizard_path: "")
    render
  end

  it "renders preview link" do
    expect(page).to have_link(
      "Download a preview of the Teaching Vacancies' reference form (opens in new tab)",
      href: organisation_job_form_preview_path(vacancy.id, :job_reference),
      target: "_blank",
    )
  end
end
