require "rails_helper"

RSpec.describe ValidatableSummaryListComponent, type: :component do
  let(:record) { build(:vacancy) }
  let(:show_errors) { false }
  let(:error_path) { "/test-path" }

  let(:list_kwargs) { { html_attributes: { key: "a-value" } } }

  let(:list) do
    described_class.new(
      record,
      error_path: error_path,
      show_errors: show_errors,
      **list_kwargs,
    )
  end

  it "inherits behaviour from the gov.uk summary list component" do
    expect(list).to be_a(GovukComponent::SummaryListComponent)
  end

  it "builds a row component for the given row information" do
    allow(ValidatableSummaryListComponent::RowComponent).to receive(:new)
    attribute = "a"
    row_kwargs = { a: 1 }

    list.with_row(attribute, **row_kwargs)
    expect(ValidatableSummaryListComponent::RowComponent).to have_received(:new).with(attribute,
                                                                                      record: record,
                                                                                      show_errors: show_errors,
                                                                                      error_path: error_path,
                                                                                      **row_kwargs)
  end
end
