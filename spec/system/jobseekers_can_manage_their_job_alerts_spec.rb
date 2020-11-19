require "rails_helper"

RSpec.describe "Jobseekers can manage their job alerts" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    allow(JobseekerAccountsFeature).to receive(:enabled?).and_return(true)
  end

  context "when logged in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_subscriptions_path
    end

    it "shows their job alerts" do
      # TODO: Implement me properly when job alerts are implemented
      expect(page).to have_content(I18n.t("jobseekers.subscriptions.index.page_title"))
    end
  end

  context "when logged out" do
    before do
      visit jobseekers_subscriptions_path
    end

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
