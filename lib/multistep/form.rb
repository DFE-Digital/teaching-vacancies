require "form_object"

module Multistep
  module Form
    extend ActiveSupport::Concern

    include FormObject

    included do
      attribute :completed_steps, default: -> { {} }
    end

    def steps
      @steps ||= self.class.steps.transform_values do |step_class|
        step_class.new.tap { |form| form.instance_variable_set(:@multistep, self) }
      end
    end

    def next_step(current_step: nil)
      current_step = completed_steps.keys.last&.to_sym if current_step.nil?
      return steps.keys.first if current_step.nil?

      current_step = current_step.to_sym
      raise "Step not completed: #{current_step}" unless completed_steps.keys.include?(current_step)

      completed_steps.to_a[0..completed_steps.keys.index(current_step)].each do |step, status|
        return step if status == :invalidated || (status == :skipped && !steps[step].skip?)
      end

      return unless (next_step = steps.keys[steps.keys.index(current_step.to_sym) + 1])
      return next_step unless steps[next_step].skip?

      self.next_step(current_step: next_step)
    end

    def previous_step(current_step:)
      completed = completed_steps.keys + [next_step].compact
      current_index = completed.index(current_step.to_sym)

      raise "Step not completed: #{current_step}" unless current_index
      return unless current_index.positive?

      previous = completed[current_index - 1]
      return previous unless completed_steps[previous] == :skipped

      previous_step(current_step: previous)
    end

    def complete_step!(step, status = :completed)
      step = step.to_sym
      completed_steps[step] = status
      return unless status == :completed

      completed_steps.keys[completed_steps.keys.index(step)+1..-1].each do |step|
        completed_steps[step] = :invalidated if steps[step].invalidate?
        completed_steps[step] = :skipped if steps[step].skip?
      end

      next_step = self.next_step(current_step: step)
      while next_step && steps[next_step].skip?
        complete_step!(next_step, :skipped)
        next_step = self.next_step(current_step: next_step)
      end
    end

    def completed?(step = nil)
      return next_step.nil? unless step

      completed_steps[step.to_sym] == :completed
    end

    def attributes
      super.merge(self.class.delegated_attributes.keys.to_h { |name| [name.to_s, public_send(name)] })
    end

    def completed_steps=(values)
      super values.to_h { |k,v| [k.to_sym, v.to_sym] }
    end

    module ClassMethods
      def steps
        @steps ||= {}
      end

      def attribute_names
        super + delegated_attributes.keys.map(&:to_s)
      end

      def delegated_attributes
        @delegated_attributes ||= {}
      end

      def delegate_attributes(*attributes, step:)
        delegated_attributes.merge!(attributes.zip([step].cycle).to_h)

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

    def invalidate?
      false
    end

    def skip?
      false
    end
  end
end
