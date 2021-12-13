require "rails_helper"

RSpec.describe FailSafe, type: :component do
  let(:my_component_class) do
    Class.new(GovukComponent::Base) do
      include FailSafe

      def self.name
        "TestComponent"
      end

      def call
        raise "an error"
      end
    end
  end

  def try_render
    render_inline(my_component_class.new(classes: [], html_attributes: {}))
  end

  context "when not in production" do
    it "doesn't hide errors during rendering" do
      expect { try_render }.to raise_error(RuntimeError)
    end
  end

  context "when in production" do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    it "hides errors raised during rendering" do
      expect { try_render }.not_to raise_error
    end

    it "notifies Rollbar of errors raised during rendering" do
      expect(Rollbar).to receive(:error).with(an_instance_of(RuntimeError))
      try_render
    end

    it "renders nothing" do
      expect(try_render.to_html).to be_blank
    end
  end
end
