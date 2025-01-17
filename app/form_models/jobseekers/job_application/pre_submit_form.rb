# frozen_string_literal: true

module Jobseekers
  module JobApplication
    class PreSubmitForm
      include ActiveModel::Model

      attr_accessor :completed_steps, :all_steps

      validate :all_steps_completed?

      private

      def all_steps_completed?
        (all_steps - completed_steps).each do |step|
          errors.add(
            :base,
            :"#{step}.incomplete",
          )
        end
      end
    end
  end
end
