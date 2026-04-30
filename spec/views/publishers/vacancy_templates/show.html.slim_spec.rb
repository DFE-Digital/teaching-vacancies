require "rails_helper"

RSpec.describe "publishers/vacancy_templates/show" do
  before do
    assign :template, vacancy_template
    render
  end

  context "with a website type" do
    let(:vacancy_template) { build_stubbed(:vacancy_template, :website) }

    it "shows the 'other' type" do
      expect(rendered).to have_content("Other")
    end
  end
end
