require "rails_helper"

RSpec.describe ValidatableSummaryListComponent, type: :component do
  let(:record) { build(:vacancy) }
  let(:show_errors) { false }
  let(:error_path) { "/test-path" }

  let(:list_kwargs) { { html_attributes: "a-value" } }

  let(:list) do
    described_class.new(
      record,
      error_path:,
      show_errors:,
      **list_kwargs,
    )
  end

  it "inherits behaviour from the gov.uk summary list component" do
    expect(list).to be_a(GovukComponent::SummaryListComponent)
  end

  it "builds row components for each row" do
    attribute = "a"
    row_kwargs = { a: 1 }
    expect(ValidatableSummaryListComponent::RowComponent).to receive(:new)
      .with(
        attribute,
        record:,
        show_errors:,
        error_path:,
        **row_kwargs,
      )
    list.row(attribute, **row_kwargs)

    attribute = "b"
    row_kwargs = { b: 2 }
    expect(ValidatableSummaryListComponent::RowComponent).to receive(:new)
      .with(
        attribute,
        record:,
        show_errors:,
        error_path:,
        **row_kwargs,
      )
    list.row(attribute, **row_kwargs)
  end
end
