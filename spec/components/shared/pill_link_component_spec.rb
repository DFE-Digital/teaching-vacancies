require "rails_helper"

RSpec.describe Shared::PillLinkComponent, type: :component do
  let(:link_path) { "#some-element" }
  let(:link_text) { "Go to this section" }

  before do
    render_inline(described_class.new(link_path: link_path, link_text: link_text))
  end

  it "renders the pill link" do
    expect(rendered_component).to eql('<a class="pill-link" href="#some-element">Go to this section</a>')
  end
end
