require "rails_helper"

RSpec.describe PublisherNotesOnJobApplicationComponent, type: :component do
  let(:notes_component) { Capybara.string(render_component) }
  let(:component) { described_class.new(job_application:, vacancy:, notes_form: note, notes_url: "something") }
  let(:render_component) { render_inline(component) }
  let(:note) { build_stubbed(:note, created_at:) }
  let(:job_application) { note.job_application }
  let(:vacancy) { job_application.vacancy }
  let(:created_at) { Time.zone.now }

  before do
    allow(job_application).to receive(:notes).and_return([note])
    notes_component
  end

  it "renders formatted note timestamp" do
    expect(notes_component.find("p.govuk-body-s").text).to include(created_at.to_fs)
  end
end
