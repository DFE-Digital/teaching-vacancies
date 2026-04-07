require "rubocop"
require "rubocop/rspec/cop_helper"
require "rubocop/rspec/expect_offense"
require_relative "../../../../../lib/rubocop/cop/custom/prefer_let_it_be"

RSpec.describe RuboCop::Cop::Custom::PreferLetItBe do
  include CopHelper
  include RuboCop::RSpec::ExpectOffense

  let(:config) { RuboCop::Config.new }
  let(:cop) { described_class.new(config) }

  context "when using let!" do
    it "registers an offense and corrects to let_it_be" do
      expect_offense(<<~RUBY)
        let!(:school) { create(:school) }
        ^^^^^^^^^^^^^ Custom/PreferLetItBe: Use `let_it_be` instead of `let!` (test-prof). If this `let!` references other `let` variables or mutable state, disable with `# rubocop:disable Custom/PreferLetItBe`.
      RUBY

      expect_correction(<<~RUBY)
        let_it_be(:school) { create(:school) }
      RUBY
    end
  end

  context "when using let_it_be" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        let_it_be(:school) { create(:school) }
      RUBY
    end
  end

  context "when using let (without bang)" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        let(:school) { create(:school) }
      RUBY
    end
  end
end
