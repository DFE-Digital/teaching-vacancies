require "rails_helper"

RSpec.describe Shared::TimelineComponent, type: :component do
  let(:kwargs) { {} }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  describe "heading" do
    context "when heading slot is defined" do
      subject! { render_inline(described_class.new) { |timeline| timeline.heading(title: "A title") } }

      it "renders heading" do
        expect(page).to have_css("aside", class: "timeline-component") do |timeline|
          expect(timeline).to have_css("h3", class: "timeline-component__heading", text: "A title")
        end
      end
    end

    context "when heading slot is not defined" do
      it "does not render heading" do
        expect(page).to have_css("aside", class: "timeline-component") do |timeline|
          expect(timeline).not_to have_css("h3", class: "timeline-component__heading")
        end
      end
    end
  end

  describe "dates" do
    context "when date slots are defined" do
      subject! do
        render_inline(described_class.new) do |timeline|
          timeline.date(key: "Date 1", value: "Jan 2020")
          timeline.date(key: "Date 2", value: "Jan 2021")
        end
      end

      it "renders dates" do
        expect(page).to have_css("aside", class: "timeline-component") do |timeline|
          expect(timeline).to have_css("ul", class: "timeline-component__dates") do |dates|
            expect(dates).to have_css("li", class: "timeline-component__date", count: 2)
          end
        end

        expect(page.all(".timeline-component__date")[0])
          .to have_css("h3", text: "Date 1")
          .and have_css("p", text: "Jan 2020")

        expect(page.all(".timeline-component__date")[1])
          .to have_css("h3", text: "Date 2")
          .and have_css("p", text: "Jan 2021")
      end
    end

    context "when date slots are not defined" do
      it "does not render dates" do
        expect(page).to have_css("aside", class: "timeline-component") do |timeline|
          expect(timeline).not_to have_css("ul", class: "timeline-component__dates")
        end
      end
    end
  end
end
