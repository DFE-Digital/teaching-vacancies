RSpec.shared_examples "a component that accepts custom HTML attributes" do
  subject! { render_inline(described_class.send(:new, html_attributes: custom_attributes, **kwargs)) }

  let(:custom_attributes) { { lang: "en-GB", style: "background-color: blue;" } }

  specify "the custom HTML attributes should be set correctly" do
    custom_attributes.each do |key, value|
      expect(page).to have_css(%(*[#{key}="#{value}"]))
    end
  end
end
