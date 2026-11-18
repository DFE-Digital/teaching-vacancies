require "rails_helper"

RSpec.describe "clear_employment_end_dates_for_currently_employed_references" do
  let(:task_path) { "lib/tasks/clear_employment_end_dates_for_currently_employed_references" }
  let(:employment_end_date) { Date.new(2023, 1, 1) }
  let!(:currently_employed_reference) { create(:job_reference, reference_request: create(:reference_request), currently_employed: true, employment_end_date: employment_end_date) }
  let!(:not_currently_employed_reference) { create(:job_reference, reference_request: create(:reference_request), currently_employed: false, employment_end_date: employment_end_date) }
  let!(:reference_without_end_date) { create(:job_reference, reference_request: create(:reference_request), currently_employed: true, employment_end_date: nil) }

  # rubocop:disable RSpec/NamedSubject
  it "clears end dates only for currently employed references" do
    subject.execute

    expect(currently_employed_reference.reload.employment_end_date).to be_nil
    expect(not_currently_employed_reference.reload.employment_end_date).to eq(employment_end_date)
    expect(reference_without_end_date.reload.employment_end_date).to be_nil
  end
  # rubocop:enable RSpec/NamedSubject
end
