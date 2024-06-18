require "rails_helper"
RSpec.describe "Publishers get email notifications from job applications" do
  include ActiveJob::TestHelper

  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, email: "test@example.com", organisations: [organisation]) }
  let(:vacancy) { create(:vacancy, :published, publisher: publisher, organisations: [organisation], publish_on: 2.days.ago) }
  let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy, submitted_at: 1.day.ago) }

  before do
    ActionMailer::Base.deliveries.clear
    allow_any_instance_of(ApplicationController).to receive(:current_organisation).and_return(organisation)

    login_publisher(publisher: publisher, organisation:)
  end

  it "publishers get an email linking to the job applications received the day before" do
    perform_enqueued_jobs do
      SendApplicationsReceivedYesterdayJob.new.perform
    end
    expect(ApplicationMailer.deliveries.count).to eq(1)
    email = ApplicationMailer.deliveries.first
    expect(email).to have_attributes(
      to: ["test@example.com"],
      subject: I18n.t("publishers.job_application_mailer.applications_received.subject", count: 1),
    )
    email_links = get_email_markdown_links(email.body.to_s)
    expect(email_links.first[:text]).to eq("View 1 new application")
    expect(email_links.first[:href]).to match(%r{organisation/jobs/#{vacancy.id}/job_applications})

    visit email_links.first[:href]
    expect(page).to have_css("h1", text: vacancy.job_title)
  end

  # Extracts the "[link text](link hreemf)" markdown links from an email body
  def get_email_markdown_links(email_body)
    email_body.scan(/\[([\w|\s]+)\]\((\S+)\)/).map { |match| { text: match[0], href: match[1] } }
  end
end
