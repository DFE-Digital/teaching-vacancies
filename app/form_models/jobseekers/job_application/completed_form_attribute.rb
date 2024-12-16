# frozen_string_literal: true

module Jobseekers
  module JobApplication
    module CompletedFormAttribute
      extend ActiveSupport::Concern

      class_methods do
        def completed_attrs(model, section)
          section_completed = "#{section}_section_completed"
          {}.tap do |new_attrs|
            if model.completed_steps.include?(section.to_s)
              new_attrs.merge!(section_completed => true)
            elsif model.in_progress_steps.include?(section.to_s)
              new_attrs.merge!(section_completed => false)
            end
          end
        end
      end
    end
  end
end
