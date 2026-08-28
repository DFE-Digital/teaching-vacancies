require "rails_helper"

RSpec.describe "backfill_about_you" do
  let(:task_path) { "lib/tasks/backfill_about_you" }

  let!(:profile) { create(:jobseeker_profile, about_you: "Hello") }

  it "backfills the about_you_richtext field" do
    expect {
      Rake::Task["backfill_about_you"].execute
    }.to change { profile.reload.about_you_richtext&.to_plain_text }.to("Hello")
  end
end
