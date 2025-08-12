require "rails_helper"

RSpec.describe TabPanelComponent, type: :component do
  subject!(:tab_panel) { Capybara.string(render_component) }

  let(:render_component) { render_inline(described_class.new(tab_name:, vacancy:, candidates:, form:)) }
  let(:form) { nil }
  let(:tab_name) { "submitted" }
  let(:vacancy) { build_stubbed(:vacancy) }
  let(:candidates) { build_stubbed_list(:job_application, 2, :status_submitted, vacancy:) }

  context "when form present" do
    let(:form) { Publishers::JobApplication::TagForm.new }

    it "job application can be selected" do
      expect(tab_panel.all('input[type="checkbox"]')).not_to be_empty
    end

    it "form points to url" do
      expected_url = Rails.application.routes.url_helpers.tag_organisation_job_job_applications_path(vacancy.id)
      expect(tab_panel.find("form")["action"]).to eq(expected_url)
      expect(tab_panel.find("form")["method"]).to eq("get")
    end

    it "table has moj multi select attributes" do
      expect(tab_panel.find("table")["data-module"]).to eq("moj-multi-select")
    end

    it "has buttons" do
      expect(tab_panel.all(".govuk-button-group")).not_to be_empty
    end
  end

  context "when form is nil" do
    it "job application cannot be selected" do
      expect(tab_panel.all('input[type="checkbox"]')).to be_empty
    end

    it "form points to no url" do
      expect(tab_panel.find("form")["action"]).to eq("")
    end

    it "table has moj multi select attributes" do
      expect(tab_panel.find("table")["data-module"]).to be_nil
    end

    it "has no buttons" do
      expect(tab_panel.all(".govuk-button-group")).to be_empty
    end
  end

  context "when candidates empty" do
    let(:candidates) { [] }

    it "renders empty section" do
      expect(tab_panel.find(".empty-section-component")).to be_present
    end
  end
end
