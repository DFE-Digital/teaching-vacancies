module Jobseekers
  module JobApplication
    class EmploymentHistoryForm < BaseForm
      include ActiveModel::Model
      include ActionView::Helpers::DateHelper
      include ActiveModel::Attributes
      include CompletedFormAttribute

      class << self
        def storable_fields
          []
        end

        def unstorable_fields
          %i[unexplained_employment_gaps_present employment_history_section_completed]
        end

        def load_form(model)
          super.merge(unexplained_employment_gaps: model.unexplained_employment_gaps).merge(completed_attrs(model, :employment_history))
        end
      end
      attr_accessor(:unexplained_employment_gaps)

      validate :employment_history_gaps_are_explained

      attribute :unexplained_employment_gaps_present, :boolean

      def employment_history_gaps_are_explained
        return unless unexplained_employment_gaps_present && employment_history_section_completed

        unexplained_employment_gaps.each_value do |details|
          gap_duration = distance_of_time_in_words(details[:started_on], details[:ended_on] || Time.zone.today)
          errors.add(:base, "You have a gap in your work history (#{gap_duration}).")
        end
      end

      completed_attribute(:employment_history)
    end
  end
end
