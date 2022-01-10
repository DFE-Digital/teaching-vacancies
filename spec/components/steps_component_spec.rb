require "rails_helper"

RSpec.describe StepsComponent, type: :component do
  let(:kwargs) { { title: } }
  let(:title) { "Stepway to Heaven" }

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when a title is passed to the component" do
    it "renders the title" do
      expect(page).to have_css("div", class: "steps-component") do |component|
        expect(component).to have_css("h2", class: "govuk-heading-s", text: "Stepway to Heaven")
      end
    end
  end

  context "when a title is not passed to the component" do
    let(:title) { nil }

    it "does not render the title" do
      expect(page).to have_css("div", class: "steps-component") do |component|
        expect(component).not_to have_css("h2", class: "govuk-heading-s", text: "Stepway to Heaven")
      end
    end
  end

  describe "steps" do
    let(:label) { "Step" }

    context "when steps slots are defined" do
      context "when current and completed are false" do
        subject! do
          render_inline(described_class.new) do |steps|
            steps.step(label:)
          end
        end

        it "renders steps with the correct classes" do
          expect(page).to have_css("div", class: "steps-component") do |component|
            expect(component).to have_css("ol", class: "steps-component__steps") do |steps|
              expect(steps).to have_css("li", class: "steps-component__step", text: "Step")
            end
          end
        end
      end

      context "when current is true and completed is false" do
        subject! do
          render_inline(described_class.new) do |steps|
            steps.step(label:, current: true, completed: false)
          end
        end

        it "renders steps with the correct classes" do
          expect(page).to have_css("div", class: "steps-component") do |component|
            expect(component).to have_css("ol", class: "steps-component__steps") do |steps|
              expect(steps).to have_css("li", class: "steps-component__step--current", text: "Step")
            end
          end
        end
      end

      context "when current is false and completed is true" do
        subject! do
          render_inline(described_class.new) do |steps|
            steps.step(label: "Step", current: false, completed: true)
          end
        end

        it "renders steps with the correct classes" do
          expect(page).to have_css("div", class: "steps-component") do |component|
            expect(component).to have_css("ol", class: "steps-component__steps") do |steps|
              expect(steps).to have_css("li", class: "steps-component__step--completed", text: "Step")
            end
          end
        end
      end

      context "when current and completed are true" do
        subject! do
          render_inline(described_class.new) do |steps|
            steps.step(label: "Step", current: true, completed: true)
          end
        end

        it "renders steps with the correct classes" do
          expect(page).to have_css("div", class: "steps-component") do |component|
            expect(component).to have_css("ol", class: "steps-component__steps") do |steps|
              expect(steps).to have_css("li", class: "steps-component__step--current", text: "Step")
            end
          end
        end
      end
    end

    context "when steps slots are not defined" do
      it "does not render steps" do
        expect(page).to have_css("div", class: "steps-component") do |c|
          expect(c).not_to have_css("ol", class: "steps-component__step")
        end
      end
    end
  end
end
