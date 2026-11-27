require "rails_helper"

RSpec.describe "jobseekers/accounts/show" do
  let(:unread_notifications_count) { 0 }

  before do
    assign(:unread_notifications_count, unread_notifications_count)
    render
  end

  it "links to each account section" do
    expect(rendered).to have_css("h1", text: I18n.t("jobseekers.accounts.show.page_title"))
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.profile.link"), href: jobseekers_profile_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.applications.link"), href: jobseekers_job_applications_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.saved_jobs.link"), href: jobseekers_saved_jobs_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.job_alerts.link"), href: jobseekers_subscriptions_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.notifications.link"), href: jobseekers_notifications_path, exact_text: true)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.help.link"), href: help_jobseekers_account_path)
  end

  context "with unread notifications" do
    let(:unread_notifications_count) { 3 }

    it "shows the unread count next to the notifications link" do
      expect(rendered).to have_link("Notifications (3 unread)", href: jobseekers_notifications_path, exact_text: true)
    end
  end

  it "shows an icon for each section" do
    %w[work bookmark notifications chat person help].each do |icon|
      expect(rendered).to have_css("span.icon.icon--account-#{icon}")
    end
  end
end
