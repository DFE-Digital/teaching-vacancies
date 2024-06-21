require "rails_helper"

RSpec.describe CardComponent, type: :component do
  subject! { render_inline(described_class.new(**kwargs)) }

  let(:kwargs) { {} }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when header, body and action blocks slots are defined" do
    subject! do
      render_inline(described_class.new) do |card|
        card.with_header { tag.h2 "Hello" }
        card.with_body { tag.p "World!" }
        card.with_action_item(link: tag.a("Click this", href: "/test-url"))
      end
    end

    it "renders header" do
      expect(page).to have_css("div", class: "card-component__header") do |header|
        expect(header).to have_css("h2", text: "Hello")
      end
    end

    it "renders body" do
      expect(page).to have_css("div", class: "card-component__body") do |body|
        expect(body).to have_css("p", text: "World!")
      end
    end

    it "renders actions" do
      expect(page).to have_css("div", class: "card-component__actions") do |actions|
        expect(actions).to have_css("a[href='/test-url']", text: "Click this")
      end
    end
  end
end
