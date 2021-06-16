require "rails_helper"

RSpec.describe NavbarComponent, type: :component do
  let(:jobseeker_signed_in) { false }
  let(:publisher_signed_in) { false }
  let(:current_organisation) { create(:school) }
  let!(:current_publisher) { create(:publisher, organisation_publishers_attributes: [{ organisation: current_organisation }]) }
  let(:kwargs) do
    {
      jobseeker_signed_in: jobseeker_signed_in,
      publisher_signed_in: publisher_signed_in,
      current_organisation: current_organisation,
      current_publisher: current_publisher,
    }
  end

  subject! { render_inline(described_class.new(**kwargs)) }

  it_behaves_like "a component that accepts custom classes"
  it_behaves_like "a component that accepts custom HTML attributes"

  context "when jobseeker is not signed in" do
    it "renders the correct links" do
      expect(rendered_component).to include(I18n.t("nav.find_job"))
      expect(rendered_component).to include(I18n.t("buttons.sign_in"))
      expect(rendered_component).to include(I18n.t("nav.for_schools"))
    end
  end

  context "when jobseeker is signed in" do
    let(:jobseeker_signed_in) { true }

    it "renders the correct links" do
      expect(rendered_component).to include(I18n.t("nav.find_job"))
      expect(rendered_component).to include(I18n.t("footer.your_account"))
      expect(rendered_component).to include(I18n.t("nav.sign_out"))
    end
  end

  context "when publisher is signed in" do
    let(:jobseeker_signed_in) { false }
    let(:publisher_signed_in) { true }

    it "renders the correct links" do
      expect(rendered_component).to include(I18n.t("nav.school_page_link"))
      expect(rendered_component).to include(I18n.t("nav.jobseekers_index_link"))
      expect(rendered_component).to include(I18n.t("nav.notifications_index_link"))
      expect(page.find(".button_to .govuk-header__link")["value"]).to eq(I18n.t("nav.sign_out"))
    end
  end
end
