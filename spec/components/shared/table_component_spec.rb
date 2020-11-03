require "rails_helper"

RSpec.describe Shared::TableComponent, type: :component do
  let(:rows) do
    [{ present: true, th: "label", td: "value" },
     { present: false, th: "other label", td: "other value", blank: "blank" }]
  end

  before do
    render_inline(described_class.new(rows: rows))
  end

  it "renders the present value" do
    expect(rendered_component).to include("<td class='govuk-table__cell'>value</td>")
  end

  it "renders the blank value" do
    expect(rendered_component).to include("<td class='govuk-table__cell'>blank</td>")
  end
end
