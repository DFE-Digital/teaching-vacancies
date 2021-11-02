require "rails_helper"

RSpec.describe "Publishers are shown the new features page" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, dismissed_new_features_page_at: nil) }

  before do
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
    login_publisher(publisher: publisher, organisation: organisation)
  end

  context "when the publisher has not dismissed the new features page" do
    before { visit organisation_path }

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
  end

  context "when logged in as a local authority" do
    let(:organisation) { create(:local_authority) }

    before { visit organisation_path }

    it "does not redirect them to the new features page" do
      expect(current_path).to eq(organisation_path)
    end
  end

  context "when they have already published jobs that enable applications" do
    let(:organisation) { create(:school) }
    let!(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation], enable_job_applications: true) }

    before { visit organisation_path }

    it "does not redirect them to the new features page" do
      expect(current_path).to eq(organisation_path)
    end
  end

  context "when they have previously dismissed the new features page" do
    let(:organisation) { create(:school) }
    let(:publisher) { create(:publisher, dismissed_new_features_page_at: 2.days.ago) }

    before { visit organisation_path }

    it "does not redirect them to the new features page" do
      expect(current_path).to eq(organisation_path)
    end
  end
end
