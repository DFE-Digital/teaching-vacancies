require "rails_helper"

RSpec.describe PillLinkComponent, type: :component do
  let(:kwargs) { { text: "Some text", href: "/a-random-link" } }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  it "renders the pill link" do
    expect(page).to have_css("a[href='/a-random-link']", class: "pill-link-component", text: "Some text")
  end
end
