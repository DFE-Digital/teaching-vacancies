require "rails_helper"
require "rake"

RSpec.describe "job_preferences:update_roles" do
  let!(:with_only_legacy_role) do
    create(:job_preferences, roles: %w[other_teaching_support])
  end

  let!(:with_mixed_roles) do
    create(:job_preferences, roles: %w[teacher other_teaching_support])
  end

  let!(:already_correct) do
    create(:job_preferences, roles: %w[other_support it_support])
  end

  it "replaces 'other_teaching_support' with 'other_support' in roles" do
    task.reenable
    task.invoke

    with_only_legacy_role.reload
    expect(with_only_legacy_role.roles).to eq(%w[other_support])

    with_mixed_roles.reload
    expect(with_mixed_roles.roles).to match_array(%w[teacher other_support])
    expect(with_mixed_roles.roles).not_to include("other_teaching_support")

    already_correct.reload
    expect(already_correct.roles).to match_array(%w[other_support it_support])
  end
end
