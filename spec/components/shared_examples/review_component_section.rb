RSpec.shared_examples ReviewSectionComponent do
  it "uses the name as the ID by default" do
    render_inline(component)
    expect(page).to have_css("div##{name}")
  end
end
