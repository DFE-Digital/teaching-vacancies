require "rails_helper"

RSpec.describe "migrate_personal_statement_to_content" do
  include_context "rake"

  let(:task_name) { "migrate_personal_statement_to_content" }

  let(:job_application_with_statement_but_no_content) { create(:job_application, personal_statement: "This is my personal statement") }

  before do
    create(:job_application, personal_statement: "Some statement").tap do |ja|
      ja.update!(content: "Some statement")
    end
    create(:job_application, personal_statement: "")
    job_application_with_statement_but_no_content.content.destroy!
    allow(MigratePersonalStatementBatchJob).to receive(:perform_later)
  end
  
  # rubocop:disable RSpec/NamedSubject
  it "queues migration jobs only for applications with personal_statement but no content" do
    subject.invoke

    expect(MigratePersonalStatementBatchJob).to have_received(:perform_later)
      .with([job_application_with_statement_but_no_content.id])
      .once
  end
  # rubocop:enable RSpec/NamedSubject
end
