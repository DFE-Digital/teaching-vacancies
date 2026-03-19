require "rails_helper"

RSpec.describe Jobseekers::JobApplication::PersonalStatementForm, type: :model do
  subject do
    described_class.new(personal_statement_section_completed: true)
  end

  it { is_expected.to validate_presence_of(:personal_statement_richtext) }

  describe "word count validation" do
    context "when word count is within limit" do
      it "is valid" do
        form = described_class.new(
          personal_statement_section_completed: true,
          personal_statement_richtext: "word " * 1500,
        )

        expect(form).to be_valid
      end
    end

    context "when word count exceeds 1,500 words" do
      it "adds an error" do
        form = described_class.new(
          personal_statement_section_completed: true,
          personal_statement_richtext: ActionText::RichText.new(body: "word " * 1501),
        )

        expect(form).not_to be_valid
        expect(form.errors[:personal_statement_richtext]).to include("Your personal statement must be 1,500 words or fewer")
      end
    end

    context "when text contains extra whitespace from rich text" do
      it "does not count blank spaces and non-breaking spaces as words" do
        # Simulates Trix editor converting multiple spaces to alternating regular spaces and non-breaking spaces
        # This caused a bug in which non breaking spaces were counted as words.
        mixed_spaces = ([" ", "\u00A0"] * 1500).join
        html_with_spaces = "<strong>Education and Experience </strong>#{mixed_spaces}I have some text here"
        rich_text = ActionText::RichText.new(body: html_with_spaces)

        form = described_class.new(
          personal_statement_section_completed: true,
          personal_statement_richtext: rich_text,
        )

        expect(form).to be_valid
      end
    end

    context "when section is not marked as completed" do
      it "does not validate word count" do
        form = described_class.new(
          personal_statement_section_completed: false,
          personal_statement_richtext: "word " * 1501,
        )

        expect(form).to be_valid
      end
    end
  end
end
