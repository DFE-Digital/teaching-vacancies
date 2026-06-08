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
          %i[unexplained_employment_gaps employment_history_section_completed employments qualifications]
        end

        def load_form(model)
          super.merge(employments: model.employments,
                      unexplained_employment_gaps: model.unexplained_employment_gaps,
                      qualifications: model.qualifications)
               .merge(completed_attrs(model, :employment_history))
        end
      end
      attr_accessor(:unexplained_employment_gaps, :employments, :qualifications, :education_gap)

      validate :employment_history_gaps_are_explained, if: -> { employment_history_section_completed }
      validate :education_gap_is_explained, if: -> { employment_history_section_completed }

      validate :employment_records_are_all_valid

      completed_attribute(:employment_history)

      private

      attribute :unexplained_employment_gaps_present, :boolean

      def employment_history_gaps_are_explained
        unexplained_employment_gaps.each_value do |details|
          gap_duration = distance_of_time_in_words(details[:started_on], details[:ended_on] || Time.zone.today)
          errors.add(:unexplained_employment_gaps, "You have a gap in your work history (#{gap_duration}).")
        end
      end

      def education_gap_is_explained
        latest_qual_year = qualifications.where(finished_studying: true).maximum(:year)
        first_job_year = employments.job.minimum(:started_on)&.year

        return unless latest_qual_year && first_job_year && latest_qual_year < first_job_year
        return if employments.any?(&:education_gap?)

        errors.add(:education_gap, :missing)
      end

      def employment_records_are_all_valid
        employments.reject(&:valid?).each do |_employment|
          errors.add(:base, :invalid_employment)
        end
      end
    end
  end
end
