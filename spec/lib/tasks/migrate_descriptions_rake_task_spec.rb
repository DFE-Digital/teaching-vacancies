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

  it "logs an error if the migration fails for a specific organisation" do
    school.reload
    allow(Organisation).to receive(:find_each).and_yield(school)
    allow(school).to receive(:update!).and_raise(StandardError, "Database timeout")

    expect(Rails.logger).to receive(:error).with("Error migrating Organisation #{school.id}: Database timeout")

    expect {
      subject.invoke
    }.not_to change(ActionText::RichText, :count)
  end
  # rubocop:enable RSpec/NamedSubject
end
