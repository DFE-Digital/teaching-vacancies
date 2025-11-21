require "rails_helper"

RSpec.describe "lockbox:migrate_action_text" do
  include_context "rake"

  let(:task_path) { "lib/tasks/migrate_lockbox_action_text" }

  # rubocop:disable RSpec/NamedSubject
  it "calls Lockbox.migrate with ActionText::RichText" do
    expect(Lockbox).to receive(:migrate).with(ActionText::RichText)
    subject.invoke
  end
  # rubocop:enable RSpec/NamedSubject
end