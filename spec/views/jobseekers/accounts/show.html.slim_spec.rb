require "rails_helper"

RSpec.describe "jobseekers/accounts/show" do
  before do
    allow(view).to receive(:jobseeker_logout_uri).and_return(URI("https://example.com/logout"))
    render
  end

  it "links to each account section" do
    expect(rendered).to have_css("h1", text: I18n.t("jobseekers.accounts.show.page_title"))
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.applications.link"), href: jobseekers_job_applications_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.saved_jobs.link"), href: jobseekers_saved_jobs_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.job_alerts.link"), href: jobseekers_subscriptions_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.notifications.link"), href: jobseekers_notifications_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.help.link"), href: help_jobseekers_account_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.sign_out.link"), href: "https://example.com/logout")
  end
end
