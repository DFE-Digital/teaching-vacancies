require "rails_helper"

RSpec.describe "migrate_school_description_to_rich_text" do
  include_context "rake"

  let!(:school) { create(:school) }

  before do
    Rake::Task["migrate_school_description_to_rich_text"].reenable

    school.rich_text_description&.destroy!
    school.update_column(:description, "Legacy text description")
  end

  # rubocop:disable RSpec/NamedSubject
  it "migrates the legacy string to ActionText" do
    expect {
      subject.invoke
    }.to change(ActionText::RichText, :count).by(1)

    expect(school.reload.description.to_plain_text).to eq("Legacy text description")
  end

  it "does not overwrite existing rich text" do
    school.reload.update!(description: "Modern Rich Text")

    expect {
      subject.invoke
    }.not_to change(ActionText::RichText, :count)

    expect(school.reload.description.to_plain_text).to eq("Modern Rich Text")
  end

  it "skips organisations that already have rich text descriptions" do
    org_with_rich_text = school
    rich_text = ActionText::RichText.new(body: "Existing rich text")
    allow(rich_text).to receive(:present?).and_return(true)
    allow(org_with_rich_text).to receive(:read_attribute).with(:description).and_return("Legacy text")
    allow(org_with_rich_text).to receive(:description).and_return(rich_text)
    allow(Organisation).to receive(:find_each).and_yield(org_with_rich_text)

    expect(org_with_rich_text).not_to receive(:update!)

    subject.invoke
  end

  it "logs an error if the migration fails for a specific organisation" do
    school.reload

    # Stub the organisation to ensure update! raises an error
    failing_org = school
    allow(failing_org).to receive(:read_attribute).with(:description).and_return("Legacy text")
    allow(failing_org).to receive(:description).and_return(ActionText::RichText.new)
    allow(failing_org).to receive(:update!).and_raise(StandardError.new("Database timeout"))
    allow(Organisation).to receive(:find_each).and_yield(failing_org)

    expect(Rails.logger).to receive(:error).with("Error migrating Organisation #{school.id}: Database timeout")

    subject.invoke
  end
  # rubocop:enable RSpec/NamedSubject
end
