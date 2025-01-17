# frozen_string_literal: true

module Jobseekers
  module JobApplication
    class PreSubmitForm
      include ActiveModel::Model

      attr_accessor :completed_steps, :all_steps

      validate :all_steps_completed?

      def all_steps_completed?
        all_steps.each do |step|
          next if step.in?(completed_steps)

          errors.add(
            :base,
            :"#{step}.incomplete",
          )
        end
      end
    end
  end
end
