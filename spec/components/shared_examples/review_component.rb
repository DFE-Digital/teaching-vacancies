RSpec.shared_examples ReviewComponent do
  it_behaves_like "a component that accepts custom classes", uses_positional_args: true
  it_behaves_like "a component that accepts custom HTML attributes", uses_positional_args: true

  context "if a header is provided" do
    before do
      component.header do
        "<p>A header</p>".html_safe
      end

      render_inline(component)
    end

    it "renders the header at the top level" do
      expect(page).to have_css("div > p", text: "A header")
    end
  end

  context "if an 'above' area is provided" do
    before do
      component.above do
        "<p>Above</p>".html_safe
      end

      render_inline(component)
    end

    it "renders the 'above' area within the column" do
      expect(page).to have_css(".govuk-grid-column-two-thirds > p", text: "Above")
    end
  end
end
