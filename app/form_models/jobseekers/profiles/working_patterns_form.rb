# frozen_string_literal: true

module Jobseekers
  module Profiles
    class WorkingPatternsForm < ProfilesForm
      WORKING_PATTERNS = %i[full_time part_time job_share].freeze

      class << self
        def fields
          [{ working_patterns: [] }, :working_pattern_details]
        end
      end

      def params_to_save
        {
          working_patterns: working_patterns,
          working_pattern_details: working_pattern_details,
        }
      end

      attribute :working_patterns, array: true
      attribute :working_pattern_details
      validates :working_patterns, presence: true
      validate :working_pattern_details_does_not_exceed_maximum_words

      def options
        WORKING_PATTERNS.to_h { |opt| [opt.to_s, I18n.t("helpers.label.publishers_job_listing_contract_information_form.working_patterns_options.#{opt}")] }
      end

      def working_pattern_details_does_not_exceed_maximum_words
        if number_of_words_exceeds_permitted_length?(50, working_pattern_details)
          errors.add(:working_pattern_details, :length)
        end
      end
    end
  end
end
