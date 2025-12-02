require "rails_helper"

RSpec.describe "migrate_personal_statement_to_content" do
  subject(:task) { rake[task_name] }

  include_context "rake"

  let!(:job_applications) do
    [
      create(:job_application, personal_statement: "Statement 1", content: nil),
      create(:job_application, personal_statement: "Statement 2", content: nil),
      create(:job_application, personal_statement: nil, content: nil),
    ]
  end

  it "enqueues migration job with all job application ids" do
    allow(MigratePersonalStatementJob).to receive(:perform_later)

    task.invoke

    expect(MigratePersonalStatementJob).to have_received(:perform_later)
      .with(match_array(job_applications.pluck(:id)))
  end
end
