require "form_object"

module Multistep
  module Form
    extend ActiveSupport::Concern

    include FormObject

    included do
      attribute :completed_steps, default: []
    end

    def steps
      @steps ||= self.class.steps.transform_values do |step_class|
        step_class.new.tap { |form| form.instance_variable_set(:@multistep, self) }
      end
    end

    def next_step(current_step: completed_steps.last&.to_sym)
      return steps.keys.first if current_step.nil?
      raise "Step not completed: #{current_step}" unless completed_steps.include?(current_step.to_s)

      steps.keys[steps.keys.index(current_step.to_sym) + 1]
    end

    def previous_step(current_step:)
      current_index = completed_steps.index(current_step.to_s)
      if current_index.nil?
        return completed_steps.last&.to_s if next_step == current_step

        raise "Step not completed: #{current_step}"
      end

      steps.keys[current_index - 1] if current_index.positive?
    end

    def complete_step!(step)
      if completed_steps.include?(step.to_s)
        self.completed_steps = completed_steps[0..completed_steps.index(step.to_s)]
      else
        completed_steps << step.to_s
      end
    end

    def attributes
      super.merge(self.class.delegated_attributes.to_h { |name| [name.to_s, public_send(name)] })
    end

    module ClassMethods
      def steps
        @steps ||= {}
      end

      def delegated_attributes
        @delegated_attributes ||= []
      end

      def delegate_attributes(*attributes, step:)
        delegated_attributes.concat attributes.map(&:to_sym)

        delegators = Module.new do
          attributes.each do |attribute|
            define_method attribute do
              steps[step].public_send(attribute)
            end

            define_method :"#{attribute}=" do |value|
              steps[step].public_send(:"#{attribute}=", value)
            end
          end
        end

        include delegators
      end

      def step(step_name, &block)
        raise "Step #{name} already defined" if steps[step_name.to_sym].present?

        step_class = steps[step_name.to_sym] = Class.new.include(Step)
        const_set(step_name.to_s.classify, step_class)
        step_class.class_eval(&block)

        delegate_attributes(*step_class.attribute_names, step: step_name)
        step_name.to_sym
      end
    end
  end

  module Step
    extend ActiveSupport::Concern

    included do
      include FormObject
    end

    attr_reader :multistep
  end
end
