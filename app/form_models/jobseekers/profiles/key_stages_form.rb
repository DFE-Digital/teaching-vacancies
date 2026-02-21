# frozen_string_literal: true

module Jobseekers
  module Profiles
    class KeyStagesForm < ProfilesForm
      class << self
        def fields
          { key_stages: [] }
        end
      end

      def params_to_save
        { key_stages: key_stages }
      end

      attribute :key_stages, array: true
      validates :key_stages, presence: true

      def options(phases:)
        options = School::PHASE_TO_KEY_STAGES_MAPPINGS.values_at(*phases.map(&:to_sym)).flatten.uniq
                                                      .to_h { |opt| [opt.to_s, I18n.t("helpers.label.jobseekers_job_preferences_form.key_stages_options.#{opt}")] }
        options.merge({ "non_teaching" => "I'm not looking for a teaching job" })
      end
    end
  end
end
