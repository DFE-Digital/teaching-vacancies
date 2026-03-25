require "rubocop"
require "rubocop/rspec/cop_helper"
require "rubocop/rspec/expect_offense"
require_relative "../../../../../lib/rubocop/cop/custom/rake_task_invoke"

RSpec.describe RuboCop::Cop::Custom::RakeTaskInvoke do
  include CopHelper
  include RuboCop::RSpec::ExpectOffense

  let(:config) { RuboCop::Config.new }
  let(:cop) { described_class.new(config) }

  context "when calling .invoke on a receiver" do
    it "registers an offense and corrects to .execute" do
      expect_offense(<<~RUBY)
        subject.invoke
                ^^^^^^ Custom/RakeTaskInvoke: Use `.execute` instead of `.invoke` when testing rake tasks. `.invoke` marks the task as already invoked, preventing it from running again in subsequent tests.
      RUBY

      expect_correction(<<~RUBY)
        subject.execute
      RUBY
    end

    it "registers an offense with arguments" do
      expect_offense(<<~RUBY)
        task.invoke("arg1")
             ^^^^^^ Custom/RakeTaskInvoke: Use `.execute` instead of `.invoke` when testing rake tasks. `.invoke` marks the task as already invoked, preventing it from running again in subsequent tests.
      RUBY

      expect_correction(<<~RUBY)
        task.execute("arg1")
      RUBY
    end

    it "registers an offense inside expect block" do
      expect_offense(<<~RUBY)
        expect { subject.invoke }.not_to raise_error
                         ^^^^^^ Custom/RakeTaskInvoke: Use `.execute` instead of `.invoke` when testing rake tasks. `.invoke` marks the task as already invoked, preventing it from running again in subsequent tests.
      RUBY

      expect_correction(<<~RUBY)
        expect { subject.execute }.not_to raise_error
      RUBY
    end
  end

  context "when using invoke in mock patterns" do
    it "does not register an offense for receive(:invoke)" do
      expect_no_offenses(<<~RUBY)
        allow(Rake::Task["db:migrate"]).to receive(:invoke)
      RUBY
    end

    it "does not register an offense for have_received(:invoke)" do
      expect_no_offenses(<<~RUBY)
        expect(Rake::Task["db:migrate"]).to have_received(:invoke)
      RUBY
    end
  end

  context "when calling .execute" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        subject.execute
      RUBY
    end
  end
end
