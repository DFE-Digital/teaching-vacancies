require "rails_helper"

RSpec.describe "Publishers are shown the new features page" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, dismissed_new_features_page_at: nil) }

  before do
    allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference))
    login_publisher(publisher: publisher, organisation: organisation)
  end

  scenario "they can dismiss the new features page" do
    visit organisation_path

    expect(current_path).to eq(new_features_path)

    check I18n.t("new_features.label")
    click_on I18n.t("buttons.continue_to_account")

    publisher.reload
    expect(current_path).to eq(organisation_path)
    expect(publisher).to be_dismissed_new_features_page_at
  end

  context "when logged in as a local authority" do
    let(:organisation) { create(:local_authority) }

    scenario "they are not redirected to the new features page" do
      visit organisation_path

      expect(current_path).to eq(organisation_path)
    end
  end

  context "when they have already published jobs that enable applications" do
    let(:organisation) { create(:school) }
    let!(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation], enable_job_applications: true) }

    scenario "they are not redirected to the new features page" do
      visit organisation_path

      expect(current_path).to eq(organisation_path)
    end
  end

  context "when they have previously dismissed the new features page" do
    let(:organisation) { create(:school) }
    let(:publisher) { create(:publisher, dismissed_new_features_page_at: 2.days.ago) }

    scenario "they are not redirected to the new features page" do
      visit organisation_path

      expect(current_path).to eq(organisation_path)
    end
  end
end
