require "rails_helper"

RSpec.describe "jobseekers/accounts/show" do
  let(:jobseeker) { create(:jobseeker) }
  let(:job_application) { create(:job_application, :status_submitted, jobseeker:) }
  let(:conversation) { create(:conversation, job_application:) }
  let(:messages) { [] }

  before do
    messages
    assign(:unread_notifications_count, jobseeker.notifications.unread.count)
    render
  end

  it "links to each account section" do
    expect(rendered).to have_css("h1", text: I18n.t("jobseekers.accounts.show.page_title"))
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.profile.link"), href: jobseekers_profile_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.applications.link"), href: jobseekers_job_applications_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.saved_jobs.link"), href: jobseekers_saved_jobs_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.job_alerts.link"), href: jobseekers_subscriptions_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.notifications.link"), href: jobseekers_notifications_path)
    expect(rendered).to have_link(I18n.t("jobseekers.accounts.show.help.link"), href: help_jobseekers_account_path)
  end

  context "with unread notifications", :perform_enqueued do
    let(:messages) { create_list(:publisher_message, 3, conversation:) }

    it "shows the unread count next to the notifications link" do
      expect(rendered).to have_link("Notifications (#{jobseeker.notifications.unread.count} unread)", href: jobseekers_notifications_path)
    end
  end

  it "shows a decorative icon for each section" do
    expect(rendered).to have_css("svg[aria-hidden='true']", count: 6)
  end
end
