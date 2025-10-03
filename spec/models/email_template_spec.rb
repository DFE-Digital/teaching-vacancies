require "rails_helper"

RSpec.describe EmailTemplate do
  context "without a name" do
    let(:template) { build(:email_template, publisher: build(:publisher), name: nil) }

    it "has the correct error message" do
      expect(template).not_to be_valid
      expect(template.errors.messages).to eq(name: ["Enter a template name"])
    end
  end

  context "without a from" do
    let(:template) { build(:email_template, publisher: build(:publisher), from: nil) }

    it "has the correct error message" do
      expect(template).not_to be_valid
      expect(template.errors.messages).to eq(from: ["Enter a from description"])
    end
  end

  context "without a subject" do
    let(:template) { build(:email_template, publisher: build(:publisher), subject: nil) }

    it "has the correct error message" do
      expect(template).not_to be_valid
      expect(template.errors.messages).to eq(subject: ["Enter a subject for the email"])
    end
  end
end
