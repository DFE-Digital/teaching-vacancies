require "rails_helper"

RSpec.describe PanelComponent, type: :component do
  let(:kwargs) { { heading_text: "heading text" } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"
end
