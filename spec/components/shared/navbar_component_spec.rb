require "rails_helper"

RSpec.describe Shared::NavbarComponent, type: :component do
  subject { described_class.new }

  context "when JobseekerAccountsFeature is enabled" do
    before do
      allow(controller).to receive(:jobseeker_signed_in?).and_return(true)
      allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
      render_inline(subject)
    end

    context "when jobseeker is signed in" do
      it "renders the correct links" do
        expect(rendered_component).to include(I18n.t("nav.find_job"))
        expect(rendered_component).to include(I18n.t("footer.your_account"))
        expect(rendered_component).to include(I18n.t("nav.sign_out"))
      end
    end

    context "when jobseeker is not signed in" do
      before do
        allow(controller).to receive(:jobseeker_signed_in?).and_return(false)
        allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
        render_inline(subject)
      end

      it "renders the correct links" do
        expect(rendered_component).to include(I18n.t("nav.find_job"))
        expect(rendered_component).to include(I18n.t("buttons.sign_in"))
        expect(rendered_component).to include(I18n.t("nav.for_schools"))
      end
    end
  end

  context "when JobseekerAccountsFeature is not enabled" do
    context "when publisher is signed in" do
      before do
        allow(controller).to receive(:publisher_signed_in?).and_return(true)
        render_inline(subject)
      end

      it "renders the correct links" do
        expect(rendered_component).to include(I18n.t("nav.school_page_link"))
        expect(rendered_component).to include(I18n.t("nav.jobseekers_index_link"))
        expect(rendered_component).to include(I18n.t("nav.sign_out"))
      end
    end

    context "when publisher is not signed in" do
      before do
        allow(controller).to receive(:publisher_signed_in?).and_return(false)
        render_inline(subject)
      end

      it "renders the correct links" do
        expect(rendered_component).to include(I18n.t("nav.find_job"))
        expect(rendered_component).to include(I18n.t("nav.sign_in"))
      end
    end
  end
end
