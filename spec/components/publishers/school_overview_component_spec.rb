require "rails_helper"

RSpec.describe Publishers::SchoolOverviewComponent, type: :component do
  let!(:inline_component) { render_inline(described_class.new(organisation:)) }

  context "when organisation is a Trust" do
    let(:organisation) { build(:trust) }

    it "does not render the school overview component" do
      expect(rendered_component).to be_blank
    end
  end

  context "when organisation is a LA" do
    let(:organisation) { build(:local_authority) }

    it "does not render the school overview component" do
      expect(rendered_component).to be_blank
    end
  end

  context "when organisation is a School" do
    let(:organisation) { create(:school) }

    it "renders the school info heading" do
      expect(inline_component.css("h2.govuk-heading-m").to_html).to include(
        I18n.t("schools.info", organisation: organisation.name),
      )
    end

    it "renders the school description" do
      expect(rendered_component).to include(organisation.description)
    end

    it "renders the school address" do
      expect(rendered_component).to include(full_address(organisation))
    end

    it "renders the school age range" do
      expect(rendered_component).to include(age_range(organisation))
    end

    it "renders the school type" do
      expect(rendered_component).to include(organisation.school_type)
    end

    it "renders the school website link" do
      expect(rendered_component).to include(organisation.url)
    end
  end

  context "when organisation does not have a url or website" do
    let(:organisation) { create(:school, website: nil, url: nil) }

    it "renders the school website is not provided" do
      expect(rendered_component).to include(I18n.t("jobs.not_defined"))
    end
  end
end
