require "rails_helper"

RSpec.describe MapComponent, type: :component do
  let(:kwargs) { { vacancy: vacancy, zoom: 10 } }
  let(:vacancy) { create(:vacancy, organisations: schools) }
  let(:schools) { create_list(:school, 2) }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "renders map component" do
    it "that has correct data attributes" do
      component = page.find(".map-component")
      expect(component["data-zoom"]).to eq("10")
    end

    it "displays a list of marker links" do
      expect(page).to have_css("ol") do |markers|
        schools.each do |school|
          expect(markers).to have_css("li a[href='#{school.url}']", text: school.name)
        end
      end
    end

    it "renders a map container" do
      expect(page).to have_css(".map-component__map")
    end
  end
end
