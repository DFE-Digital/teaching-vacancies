# frozen_string_literal: true

module Jobseekers
  module Profiles
    class PhasesForm < ProfilesForm
      class << self
        def fields
          { phases: [] }
        end
      end

      def params_to_save
        { phases: phases }
      end

      attribute :phases, array: true
      validates :phases, presence: true

      def options
        School::READABLE_PHASE_MAPPINGS.values.uniq.compact
                                       .to_h { |opt| [opt.to_s, I18n.t("jobs.education_phase_options.#{opt}")] }
      end
    end
  end
end
