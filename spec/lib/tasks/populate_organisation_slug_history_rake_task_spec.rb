require "rails_helper"

RSpec.describe "populate_organisation_slug_history" do
  before do
    create(:school)
    create(:school_group)
    # Clear any history entries created by factories
    FriendlyId::Slug.where(sluggable_type: "Organisation").delete_all
  end

  # rubocop:disable RSpec/NamedSubject
  it "creates friendly_id_slugs for all organisations with slugs" do
    expect {
      subject.execute
    }.to change { FriendlyId::Slug.where(sluggable_type: "Organisation").count }.by(2)
  end

  it "does not create duplicates when run multiple times" do
    subject.execute
    initial_count = FriendlyId::Slug.where(sluggable_type: "Organisation").count

    subject.execute

    expect(FriendlyId::Slug.where(sluggable_type: "Organisation").count).to eq(initial_count)
  end
  # rubocop:enable RSpec/NamedSubject
end
