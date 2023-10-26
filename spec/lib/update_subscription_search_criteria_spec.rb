require "rails_helper"
require "rake"

RSpec.describe "subscriptions:update_legacy_search_criteria" do
  let(:task_name) { "subscriptions:update_legacy_search_criteria" }

  subject(:task) { Rake::Task[task_name] }

  let!(:sub1) do
    create(
      :subscription,
      email: "test1@example.com",
      search_criteria: { "working_patterns" => ["flexible"], "job_roles" => ["senior_leader"] },
    )
  end

  let!(:sub2) do
    create(
      :subscription,
      email: "test2@example.com",
      search_criteria: { "working_patterns" => ["full_time"], "job_roles" => ["middle_leader"] },
    )
  end

  before do
    Rails.application.load_tasks
  end

  after do
    task.reenable
  end

  it "updates working_patterns and job_roles correctly" do
    task.invoke

    sub1.reload
    sub2.reload

    expect(sub1.search_criteria["working_patterns"]).to eq(["part_time"])
    expect(sub1.search_criteria["job_roles"]).to eq(%w[headteacher deputy_headteacher assistant_headteacher])

    expect(sub2.search_criteria["working_patterns"]).to eq(["full_time"])
    expect(sub2.search_criteria["job_roles"]).to eq(%w[head_of_year_or_phase head_of_department_or_curriculum])
  end
end
