RSpec.shared_examples "a component that accepts custom classes" do |uses_positional_args: false|
  if uses_positional_args
    subject! { render_inline(described_class.send(:new, *args, **kwargs, classes: custom_classes)) }
  else
    subject! { render_inline(described_class.send(:new, **kwargs, classes: custom_classes)) }
  end

  context "when classes are supplied as a string" do
    let(:custom_classes) { "purple-stripes" }

    context "the custom classes should be set" do
      it { expect(page).to have_css(".#{custom_classes}") }
    end
  end

  context "when classes are supplied as an array" do
    let(:custom_classes) { %w[purple-stripes yellow-background] }

    context "the custom classes should be set" do
      it { expect(page).to have_css(".#{custom_classes.join('.')}") }
    end
  end
end
