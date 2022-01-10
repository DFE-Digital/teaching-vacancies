require "rails_helper"

RSpec.describe "Publishers are shown the new features page" do
  let(:organisation) { create(:school) }

  before do
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
    login_publisher(publisher:, organisation:)
    visit organisation_path
  end

  context "when the publisher has not dismissed the new features page" do
    let(:publisher) { create(:publisher, dismissed_new_features_page_at: nil) }

    it "redirects them to the new features page after logging in" do
      expect(current_path).to eq(new_features_path)
      expect(page.get_rack_session_key("visited_new_features_page")).to eq(true)

      visit new_features_path
      check I18n.t("helpers.label.publishers_new_features_form.dismiss_options.true")
      click_on I18n.t("buttons.continue_to_account")

      publisher.reload
      expect(current_path).to eq(organisation_path)
      expect(publisher).to be_dismissed_new_features_page_at
    end

    context "when logged in as a local authority" do
      let(:organisation) { create(:local_authority) }

      it "does not redirect them to the new features page" do
        expect(current_path).to eq(organisation_path)
      end
    end

    context "when they have already used the new feature (published jobs that enable applications for education support roles)" do
      let!(:vacancy) { create(:vacancy, enable_job_applications: true, main_job_role: "education_support", publisher:, organisations: [organisation]) }

      before { visit organisation_path }

      it "does not redirect them to the new features page" do
        expect(current_path).to eq(organisation_path)
      end
    end
  end

  context "when they have previously dismissed the new features page" do
    let(:publisher) { create(:publisher, dismissed_new_features_page_at: 2.days.ago) }

    it "does not redirect them to the new features page" do
      expect(current_path).to eq(organisation_path)
    end
  end
end
