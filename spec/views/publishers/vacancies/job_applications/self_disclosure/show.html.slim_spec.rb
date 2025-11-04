require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/self_disclosure/show" do
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:job_application) do
    build_stubbed(:job_application, vacancy: vacancy,
                                    self_disclosure_request: self_disclosure_request)
  end

  before do
    assign :vacancy, vacancy
    assign :job_application, job_application
    assign :self_disclosure, SelfDisclosurePresenter.new(job_application)
    assign :notes_form, Publishers::JobApplication::NotesForm.new

    render
  end

  context "when disclosure is manually created" do
    let(:self_disclosure_request) { build_stubbed(:self_disclosure_request, :manual, self_disclosure: build_stubbed(:self_disclosure)) }

    it "renders as created" do
      expect(rendered).to have_content "created"
    end
  end
end
