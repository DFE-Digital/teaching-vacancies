require "rails_helper"

RSpec.describe MessageTemplate do
  context "without a name" do
    let(:template) { build(:message_template, publisher: build(:publisher), name: nil) }

    it "has the correct error message" do
      expect(template).not_to be_valid
      expect(template.errors.messages).to eq(name: ["Enter a template name"])
    end
  end
end
