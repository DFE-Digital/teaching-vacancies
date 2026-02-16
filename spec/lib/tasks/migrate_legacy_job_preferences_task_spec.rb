require "rails_helper"

RSpec.describe "migrate_legacy_job_preferences" do
  include_context "rake"

  let!(:pref_a) { create(:job_preferences, working_patterns: %w[term_time flexible part_time]) }
  let!(:pref_b) { create(:job_preferences, working_patterns: %w[flexible full_time]) }
  let!(:pref_c) { create(:job_preferences, working_patterns: %w[term_time]) }

  before do
    create(:job_preferences)
    create(:job_preferences, working_patterns: nil)
    subject.invoke
  end

  it "fixes up term time flexible" do
    expect(pref_a.reload.working_patterns).to match_array(%w[full_time part_time])
  end

  it "fixes up flexible full_time" do
    expect(pref_b.reload.working_patterns).to match_array(%w[part_time full_time])
  end

  it "fixes up term_time" do
    expect(pref_c.reload.working_patterns).to match_array(%w[full_time])
  end
end
