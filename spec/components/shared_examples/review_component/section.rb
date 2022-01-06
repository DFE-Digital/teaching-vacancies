RSpec.shared_examples ReviewComponent::Section do
  it_behaves_like "a component that accepts custom classes", uses_positional_args: true
  it_behaves_like "a component that accepts custom HTML attributes", uses_positional_args: true

  it "uses the name as the ID by default" do
    render_inline(component)
    expect(page).to have_css("div##{name}")
  end

  context "if an ID is provided" do
    let(:id) { "some-id" }

    it "uses the given ID" do
      render_inline(component)
      expect(page).to have_css("div#some-id")
    end
  end
end
