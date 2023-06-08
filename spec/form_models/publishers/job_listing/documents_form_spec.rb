require "rails_helper"

RSpec.describe Publishers::JobListing::DocumentsForm do
  let(:documents_form) { described_class.new(vacancy: vacancy, supporting_documents: [document]) }
  let(:vacancy) { create(:vacancy) }
  let(:attribute) { :supporting_documents }
  let(:document) { File.open(Rails.root.join("spec/fixtures/files/blank_job_spec.pdf")) }

  it "runs the validations in the form file validator" do
    expect_any_instance_of(FormFileValidator).to receive(:validate_each).with(documents_form, attribute, [document])

    documents_form.valid?
  end
end
