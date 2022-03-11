require "rails_helper"

RSpec.describe TimelineComponent, type: :component do
  let(:kwargs) { {} }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  describe "heading" do
    context "when heading slot is defined" do
      subject! { render_inline(described_class.new) { |timeline| timeline.heading(title: "A title") } }

      it "renders heading" do
        expect(page).to have_css(".timeline-component") do |timeline|
          expect(timeline).to have_css("h3", class: "timeline-component__heading", text: "A title")
        end
      end
    end

    context "when heading slot is not defined" do
      it "does not render heading" do
        expect(page).to have_css(".timeline-component") do |timeline|
          expect(timeline).not_to have_css("h4", class: "timeline-component__heading")
        end
      end
    end
  end

  describe "items" do
    context "when item slots are defined" do
      subject! do
        render_inline(described_class.new) do |timeline|
          timeline.item(key: "Item 1", value: "The first thing")
          timeline.item(key: "Item 2", value: "The second thing")
        end
      end

      it "renders items" do
        expect(page).to have_css(".timeline-component") do |timeline|
          expect(timeline).to have_css("ul", class: "timeline-component__items") do |items|
            expect(items).to have_css("li", class: "timeline-component__item", count: 2)
          end
        end

        expect(page.all(".timeline-component__item")[0])
          .to have_css("h4", text: "Item 1")
          .and have_css("p", text: "The first thing")

        expect(page.all(".timeline-component__item")[1])
          .to have_css("h4", text: "Item 2")
          .and have_css("p", text: "The second thing")
      end
    end

    context "when item slots are not defined" do
      it "does not render items" do
        expect(page).to have_css(".timeline-component") do |timeline|
          expect(timeline).not_to have_css("ul", class: "timeline-component__items")
        end
      end
    end
  end
end
