module RuboCop
  module Cop
    module Custom
      # Flags direct `.invoke` calls in rake task specs.
      #
      # Using `.invoke` in tests marks the task as "already invoked", preventing
      # it from running again in subsequent test cases. Use `.execute` instead,
      # which runs the task body without changing the invoked state.
      #
      # @example
      #   # bad
      #   subject.invoke
      #   task.invoke("arg1")
      #
      #   # good
      #   subject.execute
      #   task.execute("arg1")
      #
      class RakeTaskInvoke < Base
        extend AutoCorrector

        MSG = "Use `.execute` instead of `.invoke` when testing rake tasks. " \
              "`.invoke` marks the task as already invoked, preventing it from running again in subsequent tests.".freeze

        RESTRICT_ON_SEND = %i[invoke].freeze

        def on_send(node)
          return unless node.receiver

          add_offense(node.loc.selector) do |corrector|
            corrector.replace(node.loc.selector, "execute")
          end
        end
      end
    end
  end
end
