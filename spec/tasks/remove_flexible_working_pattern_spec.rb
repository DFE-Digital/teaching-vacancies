require "rails_helper"
require "rake"

RSpec.describe "job_preferences:remove_flexible_working_pattern" do
  before do
    Rake.application.rake_require "tasks/remove_flexible_working_pattern"
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task["job_preferences:remove_flexible_working_pattern"] }
  let(:profile) { create(:jobseeker_profile) }

  it "removes 'flexible' from working_patterns array without changing timestamps" do
    job_preferences = create(:job_preferences,
                             jobseeker_profile: profile,
                             working_patterns: %w[full_time flexible part_time])

    original_created_at = job_preferences.created_at
    original_updated_at = job_preferences.updated_at

    travel 1.second

    task.invoke

    job_preferences.reload
    expect(job_preferences.working_patterns).to match_array(%w[full_time part_time])
    expect(job_preferences.created_at).to eq(original_created_at)
    expect(job_preferences.updated_at).to eq(original_updated_at)
  end

  it "doesn't change job_preferences without 'flexible' in working_patterns" do
    job_preferences = create(:job_preferences,
                             jobseeker_profile: profile,
                             working_patterns: %w[full_time part_time])

    expect { task.invoke }.not_to(change { job_preferences.reload.working_patterns })
  end

  it "leaves empty working_patterns arrays unchanged" do
    job_preferences = create(:job_preferences,
                             jobseeker_profile: profile,
                             working_patterns: [])

    expect { task.invoke }.not_to(change { job_preferences.reload.working_patterns })
  end

  it "handles job_preferences with only 'flexible' in working_patterns" do
    profile = create(:jobseeker_profile)
    job_preferences = create(:job_preferences,
                             jobseeker_profile: profile,
                             working_patterns: %w[flexible])

    expect { task.invoke }.to change { job_preferences.reload.working_patterns }.to([])
  end
end
