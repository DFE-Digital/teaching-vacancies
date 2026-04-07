module RuboCop
  module Cop
    module Custom
      # Prefers `let_it_be` from test-prof over `let!` in RSpec specs.
      #
      # `let_it_be` creates database records once per example group (using
      # `before(:all)`) rather than before each example, significantly reducing
      # test suite runtime. Records are cleaned up via transactions after each
      # example, preserving isolation.
      #
      # Not every `let!` can be replaced: blocks that reference other `let`
      # variables, use `build`, or depend on per-example state must remain as
      # `let!`. Disable the cop inline for those cases.
      #
      # @example
      #   # bad
      #   let!(:school) { create(:school) }
      #
      #   # good
      #   let_it_be(:school) { create(:school) }
      #
      #   # also good (exempt - depends on another let variable, so disable the cop)
      #   let!(:vacancy) { create(:vacancy, organisation: school) }
      #
      class PreferLetItBe < Base
        extend AutoCorrector

        MSG = "Use `let_it_be` instead of `let!` (test-prof). " \
              "If this `let!` references other `let` variables or mutable state, " \
              "disable with `# rubocop:disable Custom/PreferLetItBe`.".freeze

        RESTRICT_ON_SEND = %i[let!].freeze

        def on_send(node)
          add_offense(node) do |corrector|
            corrector.replace(node.loc.selector, "let_it_be")
          end
        end
      end
    end
  end
end
