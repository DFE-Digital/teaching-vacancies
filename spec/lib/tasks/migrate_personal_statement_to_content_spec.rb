require "rails_helper"

RSpec.describe "migrate_personal_statement_to_content" do
  include_context "rake"

  let(:task_name) { "migrate_personal_statement_to_content" }

  let!(:job_application_with_statement) { create(:job_application, personal_statement: "This is my personal statement") }
  let!(:job_application_with_statement_and_content) do
    create(:job_application, personal_statement: "Some statement").tap do |ja|
      ja.update!(content: "Some statement")
    end
  end

  before do
    create(:job_application, personal_statement: "")
    allow(MigratePersonalStatementBatchJob).to receive(:perform_later)
  end

  # rubocop:disable RSpec/NamedSubject
  it "queues migration jobs only for applications with personal_statement but no content" do
    subject.invoke

    expect(MigratePersonalStatementBatchJob).to have_received(:perform_later)
      .with(array_including(job_application_with_statement.id, job_application_with_statement_and_content.id))
      .once
  end
  # rubocop:enable RSpec/NamedSubject
end
