require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/base/collect_references" do
  let(:form) { Publishers::JobApplication::CollectReferencesForm.new }
  let(:vacancy) { build_stubbed(:vacancy) }

  before do
    assign :form, form
    assign :vacancy, vacancy
    allow(view).to receive_messages(wizard_path: "")
    render
  end

  describe "religious reference content" do
    let(:cannot_collect) { "cannot collect religious references" }

    context "with a religious vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, :catholic) }

      it "shows religious warning text" do
        expect(rendered).to have_content(cannot_collect)
      end
    end

    context "with a non religious vacancy" do
      let(:vacancy) { build_stubbed(:vacancy) }

      it "doesnt show religious warning text" do
        expect(rendered).to have_no_content(cannot_collect)
      end
    end
  end

  it "renders preview link" do
    expect(rendered).to have_link(
      "Download a preview of the Teaching Vacancies' reference form (opens in new tab)",
      href: organisation_job_form_preview_path(vacancy.id, :job_reference),
      target: "_blank",
    )
  end
end
