module Multistep
  module Form
    module Dirty
      # I'm sorry.
      # It's either this, or overriding all the public ActiveModel::Dirty methods
      def mutations_from_database
        ActiveModel::AttributeMutationTracker.new(
          ActiveModel::AttributeSet.new(
            @attributes.send(:attributes)
              .merge(*steps.values.map { |step| step.instance_variable_get(:@attributes).send(:attributes) }),
          ),
        )
      end

      def clear_changes_information
        super
        steps.each_value(&:clear_changes_information)
      end
    end
  end
end
