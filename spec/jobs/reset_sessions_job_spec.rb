require "rails_helper"

RSpec.describe ResetSessionsJob do
  let(:rake_task) { instance_double(Rake::Task, invoke: nil) }

  before do
    allow(Rake::Task).to receive(:[]).with("db:sessions:trim").and_return(rake_task)
    allow(Rails.application).to receive(:load_tasks)
  end

  it "trims the sessions table" do
    described_class.perform_now

    expect(rake_task).to have_received(:invoke)
  end

  it "does not reload the rake tasks when they are already loaded" do
    described_class.perform_now

    expect(Rails.application).not_to have_received(:load_tasks)
  end

  it "loads the rake tasks when they are not loaded yet" do
    allow(Rake::Task).to receive(:task_defined?).with("db:sessions:trim").and_return(false)

    described_class.perform_now

    expect(Rails.application).to have_received(:load_tasks)
  end
end
