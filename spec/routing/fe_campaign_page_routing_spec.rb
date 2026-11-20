require "rails_helper"

RSpec.describe "FE job alert campaign page routing" do
  it "sends the FE campaign URL to the job alerts page" do
    expect(get("/sign-up-for-FE-job-alerts?email_contact=fred@contoso.com")).to route_to(
      controller: "subscriptions",
      action: "new",
      email_contact: "fred@contoso.com",
      fe_job_alert: true,
      search_criteria: { "ect_statuses" => %w[qts_not_needed], "phases" => %w[sixth_form_or_college] },
    )
  end
end
