require "rails_helper"

RSpec.describe "backfill_about_you" do
  let!(:profile) { create(:jobseeker_profile, about_you: "Hello") }

  # rubocop:disable RSpec/NamedSubject
  it "backfills the about_you_richtext field" do
    expect {
      subject.execute
    }.to change { profile.reload.about_you_richtext&.to_plain_text }.to("Hello")
  end
  # rubocop:enable RSpec/NamedSubject
end
