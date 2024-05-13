require "rails_helper"

RSpec.describe EditorComponent, type: :component do
  let(:form) { instance_double(GOVUKDesignSystemFormBuilder::FormBuilder) }
  let(:hint) { "hint text" }
  let(:value) { "field value" }
  let(:field_name) { "form-field-name" }
  let(:label) { { text: "editor label text", size: "s", id: "editor-id" } }
  let(:kwargs) do
    {
      form_input: form.hidden_field("hidden value"),
      field_name: field_name,
      value: value,
      label: label,
      hint: hint,
    }
  end

  before do
    allow(form).to receive(:hidden_field)
  end

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when hint is defined" do
    subject! do
      render_inline(described_class.new(**kwargs))
    end
    it "renders label text" do
      expect(page).to have_css("label[for=#{field_name}-field]", class: "govuk-label", text: label[:text])
    end

    it "renders hint text" do
      expect(page).to have_css("div##{field_name}-hint", class: "govuk-hint", text: hint)
    end

    it "renders editable area" do
      expect(page).to have_css("div", id: "editor-content-#{field_name}", text: value)
    end
  end

  context "when hint is not defined" do
    let(:hint) { "" }
    subject! do
      render_inline(described_class.new(**kwargs))
    end
    it "renders a default hint text" do
      expect(page).to have_css("div", class: "govuk-hint", text: "You can copy and paste any information and keep bullet point formatting.")
    end
  end
end
