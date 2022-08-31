require "rails_helper"

RSpec.describe ValidatableSummaryListComponent::RowComponent, type: :component do
  let(:attribute) { :job_title }
  let(:record) { build(:vacancy) }
  let(:show_errors) { false }
  let(:error_path) { "/test-path" }
  let(:html_attributes) { { a_key: "a-value" } }
  let(:options) { {} }

  let(:row) do
    described_class.new(
      attribute,
      record: record,
      error_path: error_path,
      show_errors: show_errors,
      html_attributes: html_attributes,
      **options,
    )
  end

  it "inherits behaviour from the gov.uk row component" do
    expect(row).to be_a(GovukComponent::SummaryListComponent::RowComponent)
  end

  describe "#attribute" do
    it "delegates the attribute" do
      expect(row.attribute).to eq(attribute)
    end
  end

  describe "#error_component" do
    before do
      record.errors.add(attribute, :not_present)
    end

    context "when showing errors" do
      let(:show_errors) { true }

      it "builds an error component from the record and row args" do
        expect(ValidatableSummaryListComponent::ErrorComponent).to receive(:new).with(
          errors: [ActiveModel::Error.new(record, attribute, :not_present)],
          error_path: error_path,
        ).and_call_original

        expect(row.error_component).to be_a(ValidatableSummaryListComponent::ErrorComponent)
      end
    end

    context "when hiding errors" do
      let(:show_errors) { false }

      it "builds an empty error component" do
        expect(ValidatableSummaryListComponent::ErrorComponent).to receive(:new).with(
          errors: nil,
          error_path: error_path,
        ).and_call_original

        expect(row.error_component).to be_a(ValidatableSummaryListComponent::ErrorComponent)
      end
    end
  end

  describe "#label" do
    context "when a label is provided" do
      let(:options) do
        {
          label: "Custom label",
        }
      end

      it "uses the custom label" do
        expect(row.label).to eq("Custom label")
      end
    end

    context "when a label is not provided" do
      let(:options) { {} }

      it "uses the attribute's translation" do
        expect(row.label).to eq("Job title")
      end
    end
  end

  describe "#boolean?" do
    context "when the record is a presenter" do
      let(:record) { VacancyPresenter.new(build(:vacancy)) }

      context "when the attribute is a boolean" do
        let(:attribute) { :benefits }

        it "detects as boolean" do
          expect(row).to be_boolean
        end
      end

      context "when the attribute is a string" do
        let(:attribute) { :job_title }

        it "detects as not boolean" do
          expect(row).not_to be_boolean
        end
      end
    end

    context "when the record is an active record" do
      let(:record) { build(:vacancy) }

      context "when the attribute is a boolean" do
        let(:attribute) { :benefits }

        it "detects as boolean" do
          expect(row).to be_boolean
        end
      end

      context "when the attribute is a string" do
        let(:attribute) { :job_title }

        it "detects as not boolean" do
          expect(row).not_to be_boolean
        end
      end
    end
  end

  describe "#build_text" do
    context "when the attribute is a boolean" do
      let(:attribute) { :benefits }

      it "uses 'Yes' and 'No' as values" do
        expect(row.build_text).to eq("Yes")
      end
    end

    context "when the attribute is a string" do
      let(:attribute) { :job_title }

      before do
        record.public_send("#{attribute}=", "Some value")
      end

      it "renders the text version of the value" do
        expect(row.build_text).to eq("Some value")
      end
    end

    context "when the attribute is optional" do
      let(:options) do
        {
          optional: true,
        }
      end

      context "and the attribute is present" do
        before do
          record.public_send("#{attribute}=", "Some value")
        end

        it "uses the attribute value" do
          expect(row.build_text).to eq("Some value")
        end
      end

      context "but the attribute is not present" do
        before do
          record.public_send("#{attribute}=", nil)
        end

        it "uses a 'not defined' translation" do
          expect(row.build_text).to eq("Not provided (will not be seen on published listing)")
        end
      end
    end

    context "when text is provided" do
      let(:options) do
        {
          text: "Custom text",
        }
      end

      it "uses the custom text" do
        expect(row.build_text).to eq("Custom text")
      end
    end

    context "when a value is provided for when the attribute is present" do
      let(:options) do
        {
          value_if_attribute_present: "123",
        }
      end

      context "and the attribute is present" do
        before do
          record.public_send("#{attribute}=", "Some value")
        end

        it "uses the given value" do
          expect(row.build_text).to eq("123")
        end
      end

      context "but the attribute is not present" do
        before do
          record.public_send("#{attribute}=", nil)
        end

        it "uses the attribute value" do
          expect(row.build_text).to eq("")
        end
      end
    end
  end
end
